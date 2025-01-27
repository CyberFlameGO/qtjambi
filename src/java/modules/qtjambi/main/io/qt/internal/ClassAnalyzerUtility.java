/****************************************************************************
**
** Copyright (C) 2009-2023 Dr. Peter Droste, Omix Visualization GmbH & Co. KG. All rights reserved.
**
** This file is part of Qt Jambi.
**
** $BEGIN_LICENSE$
** GNU Lesser General Public License Usage
** This file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
** 
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3.0 as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU General Public License version 3.0 requirements will be
** met: http://www.gnu.org/copyleft/gpl.html.
** $END_LICENSE$

**
** This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
** WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
**
****************************************************************************/
package io.qt.internal;

import java.io.Serializable;
import java.lang.invoke.MethodHandle;
import java.lang.invoke.MethodHandleInfo;
import java.lang.invoke.MethodHandles;
import java.lang.invoke.SerializedLambda;
import java.lang.reflect.AnnotatedElement;
import java.lang.reflect.Array;
import java.lang.reflect.Constructor;
import java.lang.reflect.GenericArrayType;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.lang.reflect.Parameter;
import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Proxy;
import java.lang.reflect.Type;
import java.lang.reflect.TypeVariable;
import java.lang.reflect.WildcardType;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Function;

import io.qt.NativeAccess;
import io.qt.QMissingVirtualOverridingException;
import io.qt.QNonVirtualOverridingException;
import io.qt.QtDeclaredFinal;
import io.qt.QtFinalOverride;
import io.qt.QtObject;
import io.qt.QtObjectInterface;
import io.qt.QtSignalEmitterInterface;
import io.qt.QtUtilities;
import io.qt.core.QMetaObject;
import io.qt.core.QMetaType;
import io.qt.core.QObject;
import io.qt.core.QPair;
import io.qt.internal.SignalUtility.AbstractSignal;

public abstract class ClassAnalyzerUtility {

	private ClassAnalyzerUtility() {
		throw new RuntimeException();
	}

	public static final boolean useAnnotatedType;
	static {
		QtJambi_LibraryUtilities.initialize();
		boolean _useAnnotatedType = false;
		try {
			java.lang.reflect.AnnotatedType.class.hashCode();
			_useAnnotatedType = true;
		}catch(Throwable t) {}
		useAnnotatedType = _useAnnotatedType;
	}
	
	private static final Map<Class<?>, Boolean> isClassGenerated = Collections.synchronizedMap(new HashMap<>());
	private static final Map<Class<?>, Function<Object,Object>> lambdaWriteReplaceHandles = Collections.synchronizedMap(new HashMap<>());
	private static interface Check {
		void check() throws Exception;
	}
	private static final Map<QPair<Class<? extends QtObjectInterface>, Class<?>>, Check> checkedClasses = Collections.synchronizedMap(new HashMap<>());

	private final static class Throwing implements Check {
		public Throwing(Exception exn) {
			super();
			this.exn = exn;
		}

		public void check() throws Exception {
			StackTraceElement[] st = Thread.currentThread().getStackTrace();
			st = Arrays.copyOfRange(st, 2, st.length - 2);
			exn.setStackTrace(st);
			throw exn;
		}

		private final Exception exn;
	}

	private static Class<?> findDefaultImplementation(Class<? extends QtObjectInterface> interfaceClass) {
		for (Class<?> cls : interfaceClass.getClasses()) {
			if (interfaceClass.isAssignableFrom(cls) && "Impl".equals(cls.getSimpleName())) {
				return cls;
			}
		}
		return null;
	}
	
	private static Method findAccessibleMethod(Method virtualProtectedMethod, Class<?> implementationClass) {
		if (implementationClass == null || isGeneratedClass(implementationClass))
			return null;
		Method method = null;
		try {
			method = implementationClass.getDeclaredMethod(virtualProtectedMethod.getName(),
					virtualProtectedMethod.getParameterTypes());
		} catch (NoSuchMethodException e) {
		}
		if (method == null) {
			return findAccessibleMethod(virtualProtectedMethod, implementationClass.getSuperclass());
		} else {
			if (virtualProtectedMethod.getReturnType() != method.getReturnType()) {
				return null;
			}
			int mod = method.getModifiers();
			return (Modifier.isPublic(mod) || Modifier.isProtected(mod)) && !Modifier.isStatic(mod) ? method : null;
		}
	}

	@NativeAccess
	private static void checkImplementation(Class<? extends QtObjectInterface> originalType, Class<?> subType) throws Exception {
		QPair<Class<? extends QtObjectInterface>, Class<?>> _pair = new QPair<>(originalType, subType);
		checkedClasses.computeIfAbsent(_pair, pair -> {
			Class<?> cls = pair.first;
			if(pair.first.isInterface()) {
				cls = findDefaultImplementation(pair.first);
				if (cls == null) {
					return new Throwing(new ClassNotFoundException("Implementation of " + pair.first.getName()));
				}
			}
			List<Method> virtualProtectedMethods = new ArrayList<>();
			List<Method> finalMethods = new ArrayList<>();
			if(pair.first.isInterface()) {
				while (cls != null) {
					for (Method method : cls.getDeclaredMethods()) {
						int mod = method.getModifiers();
						if (!Modifier.isStatic(mod)) {
							boolean isFinal = method.isAnnotationPresent(QtDeclaredFinal.class) || Modifier.isFinal(mod);
							if (!isFinal && Modifier.isProtected(mod) && Modifier.isAbstract(mod) && !virtualProtectedMethods.contains(method)) {
								virtualProtectedMethods.add(method);
							} else if (isFinal && !Modifier.isPrivate(mod) && !finalMethods.contains(method)) {
								finalMethods.add(method);
							}
						}
					}
					if (cls == QtObject.class)
						break;
					cls = cls.getSuperclass();
				}
			}else if(pair.first!=pair.second && !isGeneratedClass(pair.second)){
				while (cls != null) {
					for (Method method : cls.getDeclaredMethods()) {
						int mod = method.getModifiers();
						if (!Modifier.isStatic(mod)) {
							boolean isFinal = method.isAnnotationPresent(QtDeclaredFinal.class);
							if (isFinal && !finalMethods.contains(method)) {
								finalMethods.add(method);
							}
						}
					}
					cls = cls.getSuperclass();
					if (cls == QtObject.class)
						break;
				}
			}
			if(!virtualProtectedMethods.isEmpty() || !finalMethods.isEmpty()) {
				List<Method> missingMethods = new ArrayList<>();
				List<Method> nonFinalMethods = new ArrayList<>();
				List<Method> nonOverridableMethods = new ArrayList<>();
				for (Method method : virtualProtectedMethods) {
					if (findAccessibleMethod(method, pair.second) == null) {
						missingMethods.add(method);
					}
				}
				for (Method method : finalMethods) {
					Method implMethod = findAccessibleMethod(method, pair.second);
					if (Modifier.isProtected(method.getModifiers())) {
						if (implMethod != null && implMethod.getDeclaringClass() != pair.first
								&& implMethod.getDeclaringClass() != QtObjectInterface.class
								&& !Modifier.isFinal(implMethod.getModifiers())
								&& !nonFinalMethods.contains(implMethod)) {
							nonFinalMethods.add(implMethod);
						}
					} else if (implMethod != null) {
						if (implMethod.getDeclaringClass() != pair.first
								&& implMethod.getDeclaringClass() != QtObject.class
								&& !isGeneratedClass(implMethod.getDeclaringClass())
								&& !implMethod.isAnnotationPresent(QtFinalOverride.class)
								&& !nonOverridableMethods.contains(implMethod)) {
							nonOverridableMethods.add(implMethod);
						}
					}
				}
				if (missingMethods.size() == 1) {
					Method method = missingMethods.get(0);
					StringBuilder builder = new StringBuilder();
					if (Modifier.isPublic(method.getModifiers())) {
						builder.append("public ");
					} else if (Modifier.isProtected(method.getModifiers())) {
						builder.append("protected ");
					}
					builder.append(method.getReturnType().getName().replace('$', '.'));
					builder.append(' ');
					builder.append(method.getName());
					builder.append('(');
					Parameter[] ptypes = method.getParameters();
					for (int i = 0; i < ptypes.length; i++) {
						if (i > 0)
							builder.append(',');
						builder.append(ptypes[i].getType().getName().replace('$', '.'));
						builder.append(' ');
						builder.append(ptypes[i].getName());
					}
					builder.append(')');
					return new Throwing(new QMissingVirtualOverridingException(String.format(
							"Cannot convert %2$s to %1$s because class is required to implement virtual method: %3$s",
							pair.first.getSimpleName(), pair.second.getName(), builder)));
				} else if (missingMethods.size() > 1) {
					StringBuilder builder = new StringBuilder();
					for (Method method : missingMethods) {
						if (builder.length() != 0) {
							builder.append(',');
							builder.append(' ');
						}
						if (Modifier.isPublic(method.getModifiers())) {
							builder.append("public ");
						} else if (Modifier.isProtected(method.getModifiers())) {
							builder.append("protected ");
						}
						builder.append(method.getReturnType().getName().replace('$', '.'));
						builder.append(' ');
						builder.append(method.getName());
						builder.append('(');
						Parameter[] ptypes = method.getParameters();
						for (int i = 0; i < ptypes.length; i++) {
							if (i > 0)
								builder.append(',');
							builder.append(ptypes[i].getType().getName().replace('$', '.'));
							builder.append(' ');
							builder.append(ptypes[i].getName());
						}
						builder.append(')');
					}
					return new Throwing(new QMissingVirtualOverridingException(String.format(
							"Cannot convert %2$s to %1$s because class is required to implement following virtual methods: %3$s",
							pair.first.getSimpleName(), pair.second.getName(), builder)));
				}
	
				if (nonFinalMethods.size() == 1) {
					Method method = nonFinalMethods.get(0);
					StringBuilder builder = new StringBuilder();
					if (Modifier.isPublic(method.getModifiers())) {
						builder.append("public ");
					} else if (Modifier.isProtected(method.getModifiers())) {
						builder.append("protected ");
					}
					builder.append("final ");
					builder.append(method.getReturnType().getName().replace('$', '.'));
					builder.append(' ');
					builder.append(method.getName());
					builder.append('(');
					Parameter[] ptypes = method.getParameters();
					for (int i = 0; i < ptypes.length; i++) {
						if (i > 0)
							builder.append(',');
						builder.append(ptypes[i].getType().getName().replace('$', '.'));
						builder.append(' ');
						builder.append(ptypes[i].getName());
					}
					builder.append(')');
					return new Throwing(new QNonVirtualOverridingException(String.format(
							"Cannot convert %2$s to %1$s because following method has to be declared final: %3$s",
							pair.first.getSimpleName(), pair.second.getName(), builder), true));
				} else if (nonFinalMethods.size() > 1) {
					StringBuilder builder = new StringBuilder();
					for (Method method : nonFinalMethods) {
						if (builder.length() != 0) {
							builder.append(',');
							builder.append(' ');
						}
						if (Modifier.isPublic(method.getModifiers())) {
							builder.append("public ");
						} else if (Modifier.isProtected(method.getModifiers())) {
							builder.append("protected ");
						}
						builder.append("final ");
						builder.append(method.getReturnType().getName().replace('$', '.'));
						builder.append(' ');
						builder.append(method.getName());
						builder.append('(');
						Parameter[] ptypes = method.getParameters();
						for (int i = 0; i < ptypes.length; i++) {
							if (i > 0)
								builder.append(',');
							builder.append(ptypes[i].getType().getName().replace('$', '.'));
							builder.append(' ');
							builder.append(ptypes[i].getName());
						}
						builder.append(')');
					}
					return new Throwing(new QNonVirtualOverridingException(String.format(
							"Cannot convert %2$s to %1$s because following methods have to be declared final: %3$s",
							pair.first.getSimpleName(), pair.second.getName(), builder), true));
				}
	
				if (nonOverridableMethods.size() == 1) {
					Method method = nonOverridableMethods.get(0);
					StringBuilder builder = new StringBuilder();
					if (Modifier.isPublic(method.getModifiers())) {
						builder.append("public ");
					} else if (Modifier.isProtected(method.getModifiers())) {
						builder.append("protected ");
					}
					builder.append("final ");
					builder.append(method.getReturnType().getName().replace('$', '.'));
					builder.append(' ');
					builder.append(method.getName());
					builder.append('(');
					Parameter[] ptypes = method.getParameters();
					for (int i = 0; i < ptypes.length; i++) {
						if (i > 0)
							builder.append(',');
						builder.append(ptypes[i].getType().getName().replace('$', '.'));
						builder.append(' ');
						builder.append(ptypes[i].getName());
					}
					builder.append(')');
					return new Throwing(new QNonVirtualOverridingException(
							String.format("Cannot convert %2$s to %1$s because it overrides following final method: %3$s",
									pair.first.getSimpleName(), pair.second.getName(), builder),
							true));
				} else if (nonOverridableMethods.size() > 1) {
					StringBuilder builder = new StringBuilder();
					for (Method method : nonOverridableMethods) {
						if (builder.length() != 0) {
							builder.append(',');
							builder.append(' ');
						}
						if (Modifier.isPublic(method.getModifiers())) {
							builder.append("public ");
						} else if (Modifier.isProtected(method.getModifiers())) {
							builder.append("protected ");
						}
						builder.append("final ");
						builder.append(method.getReturnType().getName().replace('$', '.'));
						builder.append(' ');
						builder.append(method.getName());
						builder.append('(');
						Parameter[] ptypes = method.getParameters();
						for (int i = 0; i < ptypes.length; i++) {
							if (i > 0)
								builder.append(',');
							builder.append(ptypes[i].getType().getName().replace('$', '.'));
							builder.append(' ');
							builder.append(ptypes[i].getName());
						}
						builder.append(')');
					}
					return new Throwing(new QNonVirtualOverridingException(
							String.format("Cannot convert %2$s to %1$s because it overrides following final methods: %3$s",
									pair.first.getSimpleName(), pair.second.getName(), builder),
							true));
				}
			}
			return () -> {};
		}).check();
	}
	
	@SuppressWarnings("unchecked")
	@NativeAccess
	private static List<Class<? extends QtObjectInterface>> getImplementedInterfaces(Class<?> cls) {
		if (cls == null) {
			return null;
		} else {
			QtUtilities.initializePackage(cls);
			if (isGeneratedClass(cls) || cls.isInterface())
				return null;
			List<Class<? extends QtObjectInterface>> result = new ArrayList<>();
			Class<?> generatedSuperClass = findGeneratedSuperclass(cls);
			for (Class<?> _interface : cls.getInterfaces()) {
				QtUtilities.initializePackage(_interface);
				if (isGeneratedClass(_interface) && QtObjectInterface.class.isAssignableFrom(_interface)) {
					Class<? extends QtObjectInterface> __interface = (Class<? extends QtObjectInterface>) _interface;
					Class<?> defaultImplementationClass = findDefaultImplementation(__interface);
					if (defaultImplementationClass != null && defaultImplementationClass.isAssignableFrom(cls)) {
						continue;
					}
					if (generatedSuperClass != null && __interface.isAssignableFrom(generatedSuperClass)) {
						continue;
					}
					if (!result.contains(__interface)) {
						result.add(0, __interface);
						QtUtilities.initializePackage(__interface);
					}
				}
			}
			List<Class<? extends QtObjectInterface>> superInterfaces = getImplementedInterfaces(cls.getSuperclass());
			if (superInterfaces != null) {
				for (Class<? extends QtObjectInterface> _interface : superInterfaces) {
					if (!result.contains(_interface)) {
						result.add(0, _interface);
					}
				}
			}
			if (result.isEmpty() && !Proxy.isProxyClass(cls)) {
				result = null;
			} else {
				result = Collections.unmodifiableList(result);
			}
			return result;
		}
	}

	@SuppressWarnings("unchecked")
	@NativeAccess
	private static List<Class<? extends QtObjectInterface>> getAllImplementedInterfaces(Class<?> cls) {
		if (cls == null) {
			return null;
		} else {
			QtUtilities.initializePackage(cls);
			if (cls.isInterface())
				return null;
			List<Class<? extends QtObjectInterface>> result = new ArrayList<>();
			for (Class<?> _interface : cls.getInterfaces()) {
				QtUtilities.initializePackage(_interface);
				if (QtObjectInterface.class.isAssignableFrom(_interface)) {
					Class<? extends QtObjectInterface> __interface = (Class<? extends QtObjectInterface>) _interface;
					Class<?> defaultImplementationClass = findDefaultImplementation(__interface);
					if (defaultImplementationClass != null && defaultImplementationClass.isAssignableFrom(cls)) {
						continue;
					}
					if (!result.contains(__interface)) {
						result.add(0, __interface);
						QtUtilities.initializePackage(__interface);
					}
				}
			}
			List<Class<? extends QtObjectInterface>> superInterfaces = getAllImplementedInterfaces(cls.getSuperclass());
			if (superInterfaces != null) {
				for (Class<? extends QtObjectInterface> _interface : superInterfaces) {
					if (!result.contains(_interface)) {
						result.add(0, _interface);
					}
				}
			}
			if (result.isEmpty()) {
				result = null;
			} else {
				result = Collections.unmodifiableList(result);
			}
			return result;
		}
	}
	
	@NativeAccess
	private static boolean isImplementedInJava(boolean isAbstract, Method method, Class<?> expectedClass) {
		Class<?> declaringClass = method.getDeclaringClass();
		if (expectedClass.isInterface() && !declaringClass.isInterface()
				&& !expectedClass.isAssignableFrom(declaringClass)) {
			return true;
		}
		if (!expectedClass.isInterface() && declaringClass.isInterface() && isAbstract && method.isDefault()
				&& !declaringClass.isAssignableFrom(expectedClass)) {
			return true;
		}
		return !isGeneratedClass(declaringClass);
	}

	/**
	 * Returns the closest superclass of <code>obj's</code> class which is a
	 * generated class, or null if no such class is found.
	 */
	@NativeAccess
	static Class<?> findGeneratedSuperclass(Class<?> clazz) {
		while (clazz != null && !isGeneratedClass(clazz)) {
			clazz = clazz.getSuperclass();
		}
		return clazz;
	}

	@NativeAccess
	static boolean isGeneratedClass(Class<?> clazz) {
		return isClassGenerated.computeIfAbsent(clazz, cls -> {
			QtUtilities.initializePackage(cls);
			if (QtObjectInterface.class.isAssignableFrom(cls)) {
				if (isGeneratedClass(cls.getName())) {
					return true;
				} else if (cls.getSimpleName().equals("ConcreteWrapper") && cls.getEnclosingClass() != null) {
					return isGeneratedClass(cls.getEnclosingClass().getName());
				} else if (cls.getSimpleName().equals("Impl") && cls.getEnclosingClass() != null) {
					return isGeneratedClass(cls.getEnclosingClass().getName());
				}
			}
			return false;
		});
	}

	private static native boolean isGeneratedClass(String className);
	
	public static Class<?> toClass(Type type){
		if (type instanceof Class) {
			return (Class<?>) type;
		} else if (type instanceof GenericArrayType) {
			GenericArrayType gtype = (GenericArrayType) type;
			Class<?> classType = toClass(gtype.getGenericComponentType());
			return Array.newInstance(classType, 0).getClass();
		} else if (type instanceof WildcardType) {
			WildcardType wt = (WildcardType) type;
			Type[] lbounds = wt.getLowerBounds();
			Type[] ubounds = wt.getUpperBounds();
			if(lbounds==null || lbounds.length==0)
				if(ubounds==null || ubounds.length==0)
					return Object.class;
				else
					return toClass(ubounds[0]);
			else
				return toClass(lbounds[0]);
		} else if (type instanceof ParameterizedType) {
			ParameterizedType ptype = (ParameterizedType) type;
			return toClass(ptype.getRawType());
		} else if (type instanceof TypeVariable<?>) {
			TypeVariable<?> tv = (TypeVariable<?>)type;
			Type[] bounds = tv.getBounds();
			if(bounds==null || bounds.length==0)
				return Object.class;
			else
				return toClass(bounds[0]);
		} else {
			throw new RuntimeException("Unable to find raw type for " + type.getTypeName()+"; type: "+getClass(type));
		}
	}
	
	public native static <T> Class<T> getClass(T object);//Class.getClass() lead to recursive calls on android when using inside of interface default methods.
	


	public static final class LambdaInfo {
		public LambdaInfo(Class<?> ownerClass, Object owner, QObject qobject, boolean isStatic,
				MethodHandle methodHandle, Method reflectiveMethod, Constructor<?> reflectiveConstructor, List<Object> lambdaArgs) {
			super();
			this.ownerClass = ownerClass;
			this.owner = owner;
			this.qobject = qobject;
			this.isStatic = isStatic;
			this.methodHandle = methodHandle;
			this.reflectiveMethod = reflectiveMethod;
			this.reflectiveConstructor = reflectiveConstructor;
			this.lambdaArgs = lambdaArgs;
		}

		public final Class<?> ownerClass;
		public final Object owner;
		public final QObject qobject;
		public final boolean isStatic;
		public final MethodHandle methodHandle;
		public final Method reflectiveMethod;
		public final Constructor<?> reflectiveConstructor;
		public final List<Object> lambdaArgs;
	}

	public static LambdaInfo lambdaInfo(Serializable slotObject) {
		//String className = slotObject.getClass().getName();
		Class<?> slotClass = ClassAnalyzerUtility.getClass(slotObject);
		if (slotClass.isSynthetic()
				//&& className.contains("Lambda$") && className.contains("/")
				) {
			SerializedLambda serializedLambda = serializeLambdaExpression(slotObject);
			if(serializedLambda == null)
				return null;
			MethodHandle methodHandle = ReflectionUtility.lambdaSlotHandles(slotClass, serializedLambda);
			Method reflectiveMethod = null;
			Constructor<?> reflectiveConstructor = null;
			Class<?> ownerClass = null;
			Object owner = null;
			QObject qobject = null;
			List<Object> lambdaArgsList = Collections.emptyList();
			if (methodHandle != null) {
				if(serializedLambda.getImplMethodKind()==MethodHandleInfo.REF_newInvokeSpecial)
					reflectiveConstructor = MethodHandles.reflectAs(Constructor.class, methodHandle);
				else
					reflectiveMethod = MethodHandles.reflectAs(Method.class, methodHandle);
				if (methodHandle.isVarargsCollector()) {
					methodHandle = methodHandle.asFixedArity();
				}
				if (reflectiveConstructor != null || reflectiveMethod != null) {
					ownerClass = reflectiveMethod==null ? reflectiveConstructor.getDeclaringClass() : reflectiveMethod.getDeclaringClass();
					if (Modifier.isStatic(reflectiveMethod==null ? reflectiveConstructor.getModifiers() : reflectiveMethod.getModifiers())) {
						if (serializedLambda.getCapturedArgCount() > 0) {
							if (serializedLambda.getCapturedArgCount() > 0)
								lambdaArgsList = new ArrayList<>();
							for (int i = 0; i < serializedLambda.getCapturedArgCount(); i++) {
								if (qobject == null && serializedLambda.getCapturedArg(i) instanceof QObject) {
									qobject = (QObject) serializedLambda.getCapturedArg(i);
								} else {
									lambdaArgsList.add(serializedLambda.getCapturedArg(i));
								}
							}
						}
						return new LambdaInfo(ownerClass, owner, qobject, true, methodHandle, reflectiveMethod,
								reflectiveConstructor, lambdaArgsList == Collections.emptyList() ? lambdaArgsList
										: Collections.unmodifiableList(lambdaArgsList));
					} else if (serializedLambda.getCapturedArgCount() > 0
							&& ownerClass.isInstance(serializedLambda.getCapturedArg(0))) {
						if (serializedLambda.getCapturedArg(0) instanceof QObject)
							qobject = (QObject) serializedLambda.getCapturedArg(0);
						owner = serializedLambda.getCapturedArg(0);
						if (serializedLambda.getCapturedArgCount() > 1)
							lambdaArgsList = new ArrayList<>();
						for (int i = 1; i < serializedLambda.getCapturedArgCount(); i++) {
							lambdaArgsList.add(serializedLambda.getCapturedArg(i));
						}
						return new LambdaInfo(ownerClass, owner, qobject, false, methodHandle, reflectiveMethod,
								reflectiveConstructor, lambdaArgsList == Collections.emptyList() ? lambdaArgsList
										: Collections.unmodifiableList(lambdaArgsList));
					} else if (serializedLambda.getCapturedArgCount() == 0) {
						return new LambdaInfo(ownerClass, owner, qobject, false, methodHandle, reflectiveMethod,
								reflectiveConstructor, lambdaArgsList == Collections.emptyList() ? lambdaArgsList
										: Collections.unmodifiableList(lambdaArgsList));
					}
				}
			}
		}
		return null;
	}

	public static SerializedLambda serializeLambdaExpression(Serializable slotObject) {
		Class<?> slotClass = ClassAnalyzerUtility.getClass(slotObject);
		if (slotClass.isSynthetic()) {
			Function<Object,Object> writeReplaceHandle = lambdaWriteReplaceHandles.computeIfAbsent(slotClass, cls -> {
				Method writeReplace = null;
				try {
					writeReplace = cls.getDeclaredMethod("writeReplace");
				} catch (Throwable e) {}
				if(writeReplace == null) try {
					writeReplace = cls.getMethod("writeReplace");
				} catch (Throwable e) {}
				return writeReplace==null ? null : ReflectionUtility.functionFromMethod(writeReplace);
			});
			if (writeReplaceHandle != null) {
				try {
					Object serializedResult = writeReplaceHandle.apply(slotObject);
					if (serializedResult instanceof SerializedLambda) {
						return (SerializedLambda) serializedResult;
					}
				} catch (Throwable e) {
					java.util.logging.Logger.getLogger("io.qt.internal").log(java.util.logging.Level.WARNING,
							"Exception caught while analyzing lambda expression", e);
				}
			}
		}
		return null;
	}

	@SuppressWarnings("unchecked")
	public static <T> Class<T> getFactoryClass(QMetaObject.Method1<T, ?> method) {
		return (Class<T>) getFactoryClass((Serializable) method);
	}

	@SuppressWarnings("unchecked")
	public static <T> Class<T> getFactoryClass(QMetaObject.Method2<T, ?, ?> method) {
		return (Class<T>) getFactoryClass((Serializable) method);
	}

	@SuppressWarnings("unchecked")
	public static <T> Class<T> getFactoryClass(QMetaObject.Method3<T, ?, ?, ?> method) {
		return (Class<T>) getFactoryClass((Serializable) method);
	}

	@SuppressWarnings("unchecked")
	public static <T> Class<T> getFactoryClass(QMetaObject.Method4<T, ?, ?, ?, ?> method) {
		return (Class<T>) getFactoryClass((Serializable) method);
	}

	@SuppressWarnings("unchecked")
	public static <T> Class<T> getFactoryClass(QMetaObject.Method5<T, ?, ?, ?, ?, ?> method) {
		return (Class<T>) getFactoryClass((Serializable) method);
	}

	@SuppressWarnings("unchecked")
	public static <T> Class<T> getFactoryClass(QMetaObject.Method6<T, ?, ?, ?, ?, ?, ?> method) {
		return (Class<T>) getFactoryClass((Serializable) method);
	}

	@SuppressWarnings("unchecked")
	public static <T> Class<T> getFactoryClass(QMetaObject.Method7<T, ?, ?, ?, ?, ?, ?, ?> method) {
		return (Class<T>) getFactoryClass((Serializable) method);
	}

	@SuppressWarnings("unchecked")
	public static <T> Class<T> getFactoryClass(QMetaObject.Method8<T, ?, ?, ?, ?, ?, ?, ?, ?> method) {
		return (Class<T>) getFactoryClass((Serializable) method);
	}

	@SuppressWarnings("unchecked")
	public static <T> Class<T> getFactoryClass(QMetaObject.Method9<T, ?, ?, ?, ?, ?, ?, ?, ?, ?> method) {
		return (Class<T>) getFactoryClass((Serializable) method);
	}

	private static Class<?> getFactoryClass(Serializable method) {
		LambdaInfo lamdaInfo = lambdaInfo(method);
		if(lamdaInfo!=null) {
			if (lamdaInfo.reflectiveMethod != null && (lamdaInfo.lambdaArgs == null || lamdaInfo.lambdaArgs.isEmpty())
					&& !lamdaInfo.reflectiveMethod.isSynthetic() && !lamdaInfo.reflectiveMethod.isBridge()
					&& !Modifier.isStatic(lamdaInfo.reflectiveMethod.getModifiers())) {
				return lamdaInfo.reflectiveMethod.getDeclaringClass();
			}else if (lamdaInfo.reflectiveConstructor != null && (lamdaInfo.lambdaArgs == null || lamdaInfo.lambdaArgs.isEmpty())
					&& !lamdaInfo.reflectiveConstructor.isSynthetic()
					&& !Modifier.isStatic(lamdaInfo.reflectiveConstructor.getModifiers())) {
				return lamdaInfo.reflectiveConstructor.getDeclaringClass();
			}
		}
		return null;
	}

	@SuppressWarnings("unchecked")
	public static <R> Class<R> getReturnType(QMetaObject.Method1<?, R> method) {
		LambdaInfo lamdaInfo = lambdaInfo(method);
		if (lamdaInfo!=null && lamdaInfo.methodHandle != null) {
			return (Class<R>) lamdaInfo.methodHandle.type().returnType();
		} else {
			return null;
		}
	}
	
	static <S extends java.io.Serializable> io.qt.core.QObject lambdaContext(S lambdaExpression){
		if(lambdaExpression instanceof AbstractSignal) {
			QtSignalEmitterInterface containingObject = ((AbstractSignal) lambdaExpression).containingObject();
			if(containingObject instanceof QObject)
				return (QObject)containingObject;
		}
		LambdaInfo lambdaInfo = lambdaInfo(lambdaExpression);
		if (lambdaInfo != null) {
			if(lambdaInfo.owner instanceof AbstractSignal) {
				QtSignalEmitterInterface containingObject = ((AbstractSignal) lambdaInfo.owner).containingObject();
				if(containingObject instanceof QObject)
					return (QObject)containingObject;
			}
			return lambdaInfo.qobject;
		} else {
			return null;
		}
	}
	
	static <S extends java.io.Serializable> Class<?> lambdaReturnType(Class<S> type, S lambdaExpression){
		LambdaInfo lamdaInfo = lambdaInfo(lambdaExpression);
		if (lamdaInfo!=null && lamdaInfo.methodHandle != null) {
			return lamdaInfo.methodHandle.type().returnType();
		} else {
			Class<?> objectType = ClassAnalyzerUtility.getClass(lambdaExpression);
			if(type.isInterface() && !objectType.isSynthetic()) {
				Method functionalMethod = null;
				for(Method method : type.getMethods()) {
					if(!method.isDefault() && method.getDeclaringClass()!=Object.class) {
						functionalMethod = method;
						break;
					}
				}
				if(functionalMethod!=null) {
					try {
						Method mtd = objectType.getMethod(functionalMethod.getName(), functionalMethod.getParameterTypes());
						if(mtd==null || mtd.isBridge() || mtd.isDefault() || Modifier.isAbstract(mtd.getModifiers())) {
							for(Method _mtd : objectType.getMethods()) {
								if(!_mtd.isBridge()
										&& !_mtd.isDefault()
										&& _mtd.getName().equals(functionalMethod.getName())
										&& _mtd.getParameterCount()==functionalMethod.getParameterCount()) {
									mtd = _mtd;
									break;
								}
							}
						}
						if(mtd!=null && !mtd.isBridge() && !mtd.isDefault() && !Modifier.isAbstract(mtd.getModifiers()))
							return mtd.getReturnType();
					} catch (Exception e) {
					}
				}
			}
			return null;
		}
	}
	
	static <S extends java.io.Serializable> int[] lambdaMetaTypes(Class<S> type, S lambdaExpression) {
		LambdaInfo lamdaInfo = lambdaInfo(lambdaExpression);
		if (lamdaInfo!=null && lamdaInfo.reflectiveMethod != null) {
			int[] metaTypes = new int[1+lamdaInfo.reflectiveMethod.getParameterCount()];
			AnnotatedElement rt = null;
			if(useAnnotatedType)
				rt = lamdaInfo.reflectiveMethod.getAnnotatedReturnType();
			Class<?> returnType = lamdaInfo.reflectiveMethod.getReturnType();
			Type genericReturnType = lamdaInfo.reflectiveMethod.getGenericReturnType();
			metaTypes[0] = MetaTypeUtility.registerMetaType(returnType, genericReturnType, rt, false, false);
			Parameter[] parameters = lamdaInfo.reflectiveMethod.getParameters();
			for (int i = 0; i < parameters.length; i++) {
				metaTypes[i+1] = MetaTypeUtility.registerMetaType(parameters[i]);
			}
			return metaTypes;
		}else {
			Class<?> objectType = ClassAnalyzerUtility.getClass(lambdaExpression);
			if(type.isInterface() && !objectType.isSynthetic()) {
				Method functionalMethod = null;
				for(Method method : type.getMethods()) {
					if(!method.isDefault() && method.getDeclaringClass()!=Object.class) {
						functionalMethod = method;
						break;
					}
				}
				if(functionalMethod!=null) {
					try {
						Method mtd = objectType.getMethod(functionalMethod.getName(), functionalMethod.getParameterTypes());
						if(mtd==null || mtd.isBridge() || mtd.isDefault() || Modifier.isAbstract(mtd.getModifiers())) {
							for(Method _mtd : objectType.getMethods()) {
								if(!_mtd.isBridge()
										&& !_mtd.isDefault()
										&& _mtd.getName().equals(functionalMethod.getName())
										&& _mtd.getParameterCount()==functionalMethod.getParameterCount()) {
									mtd = _mtd;
									break;
								}
							}
						}
						if(mtd!=null && !mtd.isBridge() && !mtd.isDefault() && !Modifier.isAbstract(mtd.getModifiers())) {
							int[] metaTypes = new int[mtd.getParameterCount()+1];
							if(mtd.getReturnType()==void.class) {
								metaTypes[0] = QMetaType.Type.Void.value();
							}else {
								AnnotatedElement ae = null;
								if(useAnnotatedType) {
									ae = mtd.getAnnotatedReturnType();
								}
								Class<?> returnType = mtd.getReturnType();
								Type genericReturnType = mtd.getGenericReturnType();
								metaTypes[0] = MetaTypeUtility.registerMetaType(returnType, genericReturnType, ae, false, false);
							}
							Parameter[] params = mtd.getParameters();
							for (int i = 0; i < params.length; i++) {
								metaTypes[i+1] = MetaTypeUtility.registerMetaType(params[i]);
							}
							return metaTypes;
						}
					} catch (Exception e) {
					}
				}
			}
			return null;
		}
	}
	
	static <S extends java.io.Serializable> Class<?>[] lambdaClassTypes(Class<S> type, S lambdaExpression) {
		LambdaInfo lamdaInfo = lambdaInfo(lambdaExpression);
		if (lamdaInfo!=null && lamdaInfo.reflectiveMethod != null) {
			Class<?>[] classTypes = new Class[1+lamdaInfo.reflectiveMethod.getParameterCount()];
			classTypes[0] = lamdaInfo.reflectiveMethod.getReturnType();
			Parameter[] parameters = lamdaInfo.reflectiveMethod.getParameters();
			for (int i = 0; i < parameters.length; i++) {
				classTypes[i+1] = parameters[i].getType();
			}
			return classTypes;
		}else {
			Class<?> objectType = ClassAnalyzerUtility.getClass(lambdaExpression);
			if(type.isInterface() && !objectType.isSynthetic()) {
				Method functionalMethod = null;
				for(Method method : type.getMethods()) {
					if(!method.isDefault() && method.getDeclaringClass()!=Object.class) {
						functionalMethod = method;
						break;
					}
				}
				if(functionalMethod!=null) {
					try {
						Method mtd = objectType.getMethod(functionalMethod.getName(), functionalMethod.getParameterTypes());
						if(mtd==null || mtd.isBridge() || mtd.isDefault() || Modifier.isAbstract(mtd.getModifiers())) {
							for(Method _mtd : objectType.getMethods()) {
								if(!_mtd.isBridge()
										&& !_mtd.isDefault()
										&& _mtd.getName().equals(functionalMethod.getName())
										&& _mtd.getParameterCount()==functionalMethod.getParameterCount()) {
									mtd = _mtd;
									break;
								}
							}
						}
						if(mtd!=null && !mtd.isBridge() && !mtd.isDefault() && !Modifier.isAbstract(mtd.getModifiers())) {
							Class<?>[] classTypes = new Class[mtd.getParameterCount()+1];
							if(mtd.getReturnType()==void.class) {
								classTypes[0] = void.class;
							}else {
								classTypes[0] = mtd.getReturnType();
							}
							Parameter[] params = mtd.getParameters();
							for (int i = 0; i < params.length; i++) {
								classTypes[i+1] = params[i].getType();
							}
							return classTypes;
						}
					} catch (Exception e) {
					}
				}
			}
			return null;
		}
	}
	
	static <S extends java.io.Serializable> java.lang.reflect.Executable lambdaExecutable(S lambdaExpression){
		LambdaInfo lamdaInfo = lambdaInfo(lambdaExpression);
		if (lamdaInfo!=null) {
			if(lamdaInfo.reflectiveMethod != null)
				return lamdaInfo.reflectiveMethod;
			else
				return lamdaInfo.reflectiveConstructor;
		}else 
			return null;
	}
	
	@NativeAccess
	private static String objectToString(Object object) {
		if (object != null) {
			try {
				Method toStringMethod = getClass(object).getMethod("toString");
				if (toStringMethod.getDeclaringClass() != Object.class) {
					return object.toString();
				}
			} catch (Exception e) {
			}
		}
		return null;
	}
}
