/****************************************************************************
**
** Copyright (C) 1992-2009 Nokia. All rights reserved.
** Copyright (C) 2009-2022 Dr. Peter Droste, Omix Visualization GmbH & Co. KG. All rights reserved.
**
** This file is part of Qt Jambi.
**
** ** $BEGIN_LICENSE$
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

import static io.qt.internal.QtJambiInternal.internalTypeNameOfClass;
import static io.qt.internal.QtJambiInternal.registerMetaType;
import static io.qt.internal.QtJambiInternal.registerRefMetaType;

import java.lang.reflect.AccessibleObject;
import java.lang.reflect.AnnotatedElement;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Member;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.lang.reflect.Parameter;
import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;
import java.util.AbstractList;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.logging.Logger;

import io.qt.NativeAccess;
import io.qt.QFlags;
import io.qt.QSignalDeclarationException;
import io.qt.QSignalInitializationException;
import io.qt.QtByteEnumerator;
import io.qt.QtClassInfo;
import io.qt.QtEnumerator;
import io.qt.QtInvokable;
import io.qt.QtLongEnumerator;
import io.qt.QtMetaType;
import io.qt.QtPointerType;
import io.qt.QtPropertyConstant;
import io.qt.QtPropertyDesignable;
import io.qt.QtPropertyMember;
import io.qt.QtPropertyNotify;
import io.qt.QtPropertyReader;
import io.qt.QtPropertyRequired;
import io.qt.QtPropertyResetter;
import io.qt.QtPropertyScriptable;
import io.qt.QtPropertyStored;
import io.qt.QtPropertyUser;
import io.qt.QtPropertyWriter;
import io.qt.QtReferenceType;
import io.qt.QtShortEnumerator;
import io.qt.QtUninvokable;
import io.qt.QtUnlistedEnum;
import io.qt.core.QDeclarableSignals;
import io.qt.core.QMetaObject;
import io.qt.core.QMetaType;
import io.qt.core.QObject;
import io.qt.core.QPair;
import io.qt.core.QStaticMemberSignals;
import io.qt.internal.QtJambiSignals.SignalParameterType;


/**
 * Methods to help construct the fake meta object.
 */
final class MetaObjectTools extends AbstractMetaObjectTools{
	
	private static class PrivateConstructorAccess extends io.qt.QtObject{
    	static Class<?> type(){
    		return QPrivateConstructor.class;
    	}
    }
	
	private static class DeclarativeConstructorAccess extends io.qt.core.QObject{
    	static Class<?> type(){
    		return QDeclarativeConstructor.class;
    	}
    }
    
    private MetaObjectTools() { throw new RuntimeException();}
    
    static class AnnotationInfo{
    	AnnotationInfo(String name, boolean enabled) {
			super();
			this.name = name;
			this.enabled = enabled;
		}
		final String name; 
		final boolean enabled;
    }
    
    static class QPropertyTypeInfo{
		QPropertyTypeInfo(Class<?> propertyType, Type genericPropertyType, AnnotatedElement annotatedPropertyType, boolean isPointer,
				boolean isReference, boolean isWritable) {
			super();
			this.propertyType = propertyType;
			this.genericPropertyType = genericPropertyType;
			this.annotatedPropertyType = annotatedPropertyType;
			this.isPointer = isPointer;
			this.isReference = isReference;
			this.isWritable = isWritable;
		}
		final Class<?> propertyType;
    	final Type genericPropertyType;
    	final AnnotatedElement annotatedPropertyType;
    	final boolean isPointer;
    	final boolean isReference;
    	final boolean isWritable;
    }
    
    static class PropertyAnnotation {
        enum AnnotationType {
            Reader,
            Writer,
            Resetter,
            Notify,
            Bindable,
            Member
        }

        private Member member;
        private String name = null;
        private boolean enabled;
        private AnnotationType type;


        private PropertyAnnotation(String name, Member member, boolean enabled, AnnotationType type) {
            this.name = name;
            this.member = member;
            this.enabled = enabled;
            this.type = type;
        }

        private static String removeAndLowercaseFirst(String name, int count) {
            return Character.toLowerCase(name.charAt(count)) + name.substring(count + 1);
        }

        private String getNameFromMethod(Member member) {
        	String name = member.getName();
            switch(type) {
            case Resetter:
            	if(name.startsWith("reset") && name.length() > 5) {
            		return removeAndLowercaseFirst(name, 5);
            	}
                return "";
            case Bindable:
            	if(name.startsWith("bindable") && name.length() > 8) {
            		return removeAndLowercaseFirst(name, 8);
            	}
                return "";
            case Member:
            	if(name.endsWith("Prop") && name.length() > 4) {
            		return name.substring(0, name.length()-4);
            	}
            	if(name.endsWith("Property") && name.length() > 8) {
            		return name.substring(0, name.length()-8);
            	}
                return name;
            case Notify:
            	if(name.endsWith("Changed") && name.length() > 7) {
            		return name.substring(0, name.length()-7);
            	}
                return "";
            case Reader:
                int len = name.length();
                if (name.startsWith("get") && len > 3)
                    name = removeAndLowercaseFirst(name, 3);
                else if (isBoolean(((Method)member).getReturnType()) && name.startsWith("is") && len > 2)
                    name = removeAndLowercaseFirst(name, 2);
                else if (isBoolean(((Method)member).getReturnType()) && name.startsWith("has") && len > 3)
                    name = removeAndLowercaseFirst(name, 3);
                return name;
            case Writer: // starts with "set"
        	default:
                if (!name.startsWith("set") || name.length() <= 3) {
                    throw new IllegalArgumentException("The correct pattern for setter accessor names is setXxx where Xxx is the property name with upper case initial.");
                }
                name = removeAndLowercaseFirst(name, 3);
                return name;
            }
        }

        String name() {
            if (name == null || name.length() == 0)
                name = getNameFromMethod(member);

            return name;
        }

        boolean enabled() {
            return enabled;
        }

        static PropertyAnnotation readerAnnotation(Method method) {
            QtPropertyReader reader = method.getAnnotation(QtPropertyReader.class);
            return reader == null ? null : new PropertyAnnotation(reader.name(), method, reader.enabled(), AnnotationType.Reader);
        }
        
        static PropertyAnnotation memberAnnotation(Field field) {
            QtPropertyMember member = field.getAnnotation(QtPropertyMember.class);
            return member == null ? null : new PropertyAnnotation(member.name(), field, member.enabled(), AnnotationType.Member);
        }

        static PropertyAnnotation writerAnnotation(Method method) {
            QtPropertyWriter writer = method.getAnnotation(QtPropertyWriter.class);
            return writer == null ? null : new PropertyAnnotation(writer.name(), method, writer.enabled(), AnnotationType.Writer);
        }

        static PropertyAnnotation resetterAnnotation(Method method) {
            QtPropertyResetter resetter = method.getAnnotation(QtPropertyResetter.class);
            return resetter == null ? null : new PropertyAnnotation(resetter.name(), method, resetter.enabled(), AnnotationType.Resetter);
        }
        
        static PropertyAnnotation notifyAnnotation(Field field) {
            QtPropertyNotify notify = field.getAnnotation(QtPropertyNotify.class);
            return notify == null ? null : new PropertyAnnotation(notify.name(), field, notify.enabled(), AnnotationType.Notify);
        }
        
        static PropertyAnnotation bindableAnnotation(Method method) {
        	AnnotationInfo bindable = analyzeBindableAnnotation(method);
            return bindable == null ? null : new PropertyAnnotation(bindable.name, method, bindable.enabled, AnnotationType.Bindable);
        }
    }

    private static class StringList extends ArrayList<String>{
        private static final long serialVersionUID = -7793211808465428478L;

        @Override
        public boolean add(String e) {
            if (!contains(e))
                return super.add(e);
            return true;
        }
    }
    
    @NativeAccess
	static class SignalInfo{
		SignalInfo(Field field, List<SignalParameterType> signalTypes, Class<?> signalClass, int[] signalMetaTypes, long methodId) {
			super();
			this.field = field;
			this.signalTypes = Collections.unmodifiableList(signalTypes);
			this.signalClass = signalClass;
			this.signalMetaTypes = signalMetaTypes;
			this.methodId = methodId;
		}
		
		final @NativeAccess Field field;
		final @NativeAccess List<SignalParameterType> signalTypes;
		final @NativeAccess Class<?> signalClass;
		final @NativeAccess int[] signalMetaTypes;
		final @NativeAccess long methodId;
	}
    
    @NativeAccess
    private static class MetaData {
    	int addStringData(String data) {
    		int index = stringData.indexOf(data);
    		if(index<0) {
    			index = stringData.size();
    			stringData.add(data);
    		}
    		return index;
    	}
        final @NativeAccess List<Integer> metaData = new ArrayList<>();
        final @NativeAccess List<String>  stringData = new StringList();

        final @NativeAccess List<SignalInfo>  signalInfos = new ArrayList<>();
        final @NativeAccess List<Method>  methods = new ArrayList<>();
        final @NativeAccess List<int[]>   methodMetaTypes = new ArrayList<>();
        final @NativeAccess List<Constructor<?>> constructors = new ArrayList<>();
        final @NativeAccess List<int[]>   constructorMetaTypes = new ArrayList<>();

        final @NativeAccess List<Method>  propertyReaders = new ArrayList<>();
        final @NativeAccess List<Method>  propertyWriters = new ArrayList<>();
        final @NativeAccess List<Method>  propertyResetters = new ArrayList<>();
        final @NativeAccess List<Integer> propertyNotifies = new ArrayList<>();
        final @NativeAccess List<Method>  propertyBindables = new ArrayList<>();
        final @NativeAccess List<Field>   propertyQPropertyFields = new ArrayList<>();
        final @NativeAccess List<Field>   propertyMemberFields = new ArrayList<>();
        final @NativeAccess List<Method>  propertyDesignableResolvers = new ArrayList<>();
        final @NativeAccess List<Method>  propertyScriptableResolvers = new ArrayList<>();
        final @NativeAccess List<Method>  propertyEditableResolvers = new ArrayList<>();
        final @NativeAccess List<Method>  propertyStoredResolvers = new ArrayList<>();
        final @NativeAccess List<Method>  propertyUserResolvers = new ArrayList<>();
        final @NativeAccess List<int[]>   propertyMetaTypes = new ArrayList<>();
        final @NativeAccess List<Class<?>>   propertyClassTypes = new ArrayList<>();
        final @NativeAccess List<Class<?>> relatedMetaObjects = new ArrayList<>();

        @NativeAccess boolean hasStaticMembers;
        final @NativeAccess List<Integer> metaTypes = new ArrayList<>();
    }

    private static Method notBogus(Method method, String propertyName, Class<?> paramType) {
        if (method == null)
            return null;

        PropertyAnnotation reader = PropertyAnnotation.readerAnnotation(method);
        if (reader != null
            && (!reader.name().equals(propertyName)
                || !reader.enabled()
                || !method.getReturnType().isAssignableFrom(paramType))) {
            return null;
        } else {
            return method;
        }
    }

    private static int queryEnums(Class<?> clazz, Hashtable<String, Class<?>> enums) {
        int enumConstantCount = 0;

        Class<?> declaredClasses[] = clazz.getDeclaredClasses();
        for (Class<?> declaredClass : declaredClasses)
            enumConstantCount += putEnumTypeInHash(declaredClass, enums);

        return enumConstantCount;
    }

    @NativeAccess
    private static Class<?> getEnumForQFlags(Class<?> flagsType) {
        Type t = flagsType.getGenericSuperclass();
        if (t instanceof ParameterizedType) {
            Type typeArguments[] = ((ParameterizedType)t).getActualTypeArguments();
            return ((Class<?>) typeArguments[0]);
        }

        return null;
    }

    private static int putEnumTypeInHash(Class<?> type, Hashtable<String, Class<?>> enums) {
        Class<?> flagsType = QFlags.class.isAssignableFrom(type) ? type : null;
        Class<?> enumType = type.isEnum() ? type : null;
        if (enumType == null && flagsType != null) {
            enumType = getEnumForQFlags(flagsType);
        }

        if (enumType == null)
            return 0;

        // Since Qt supports enums that are not part of the meta object
        // we need to check whether the enum can actually be used in
        // a property.
        Class<?> enclosingClass = enumType.getEnclosingClass();
        if (enclosingClass == null){
            return -1;
        }
        if (enumType.isAnnotationPresent(QtUnlistedEnum.class)) {
            return -1;
        }

        int enumConstantCount = 0;
        if (!enums.contains(enumType.getName())) {
            enums.put(enumType.getName(), enumType);
        	Object[] enumConstants = enumType.getEnumConstants();
            enumConstantCount = enumConstants==null ? 0 : enumConstants.length;
        }

        if (flagsType != null && !enums.contains(flagsType.getName()))
            enums.put(flagsType.getName(), flagsType);

        return enumConstantCount;
    }
    
    private static boolean isEnumAllowedForProperty(Class<?> type) {
        Class<?> flagsType = QFlags.class.isAssignableFrom(type) ? type : null;
        Class<?> enumType = type.isEnum() ? type : null;
        if (enumType == null && flagsType != null) {
            enumType = getEnumForQFlags(flagsType);
        }

        if (enumType == null)
            return false;

        // Since Qt supports enums that are not part of the meta object
        // we need to check whether the enum can actually be used in
        // a property.
        Class<?> enclosingClass = enumType.getEnclosingClass();
        if (enclosingClass == null){
            return false;
        }
        if(enumType.isAnnotationPresent(QtUnlistedEnum.class))
            return false;
        return true;
    }

    private static Object isDesignable(AccessibleObject member, Class<?> clazz) {
        QtPropertyDesignable designable = member.getAnnotation(QtPropertyDesignable.class);

        if (designable != null) {
            String value = designable.value();

            if (value.equalsIgnoreCase("true")) {
                return Boolean.TRUE;
            } else if (value.equalsIgnoreCase("false")) {
                return Boolean.FALSE;
            } else if(QtJambiInternal.majorVersion()<6) { 
            	try {
	                Method m = clazz.getMethod(value);
	                if (isBoolean(m.getReturnType()))
	                    return m;
	                else
	                    throw new RuntimeException("Wrong return type of designable method '" + m.getName() + "'");
	            } catch (Throwable t) {
	                java.util.logging.Logger.getLogger("io.qt.internal").log(java.util.logging.Level.SEVERE, "", t);
	            }
            }
        }

        return Boolean.TRUE;
    }
    
    private static Object isScriptable(AccessibleObject member, Class<?> clazz) {
        QtPropertyScriptable scriptable = member.getAnnotation(QtPropertyScriptable.class);

        if (scriptable != null) {
            String value = scriptable.value();

            if (value.equalsIgnoreCase("true")) {
                return Boolean.TRUE;
            } else if (value.equalsIgnoreCase("false")) {
                return Boolean.FALSE;
            } else if(QtJambiInternal.majorVersion()<6) {
            	try {
	                Method m = clazz.getMethod(value);
	                if (isBoolean(m.getReturnType()))
	                    return m;
	                else
	                    throw new RuntimeException("Wrong return type of scriptable method '" + m.getName() + "'");
	            } catch (Throwable t) {
	                java.util.logging.Logger.getLogger("io.qt.internal").log(java.util.logging.Level.SEVERE, "", t);
	            }
            }
        }
        return Boolean.TRUE;
    }
    
    private static Object isStored(AccessibleObject member, Class<?> clazz) {
        QtPropertyStored stored = member.getAnnotation(QtPropertyStored.class);

        if (stored != null) {
            String value = stored.value();

            if (value.equalsIgnoreCase("true")) {
                return Boolean.TRUE;
            } else if (value.equalsIgnoreCase("false")) {
                return Boolean.FALSE;
            } else if(QtJambiInternal.majorVersion()<6) {
            	try {
	                Method m = clazz.getMethod(value);
	                if (isBoolean(m.getReturnType()))
	                    return m;
	                else
	                    throw new RuntimeException("Wrong return type of scriptable method '" + m.getName() + "'");
	            } catch (Throwable t) {
	                java.util.logging.Logger.getLogger("io.qt.internal").log(java.util.logging.Level.SEVERE, "", t);
	            }
            }
        }
        return Boolean.TRUE;
    }
    
    private static Object isEditable(AccessibleObject member, Class<?> clazz) {
        return Boolean.TRUE;
    }

    private static boolean isValidSetter(Method declaredMethod) {
        return (declaredMethod.getParameterCount() == 1
                && declaredMethod.getReturnType() == Void.TYPE);
    }

    private static Method getDeclaredMethod(Class<?> clazz, String name, Class<?> args[]) {
        try {
            return clazz.getDeclaredMethod(name, args);
        } catch (NoSuchMethodException e) {
            return null;
        }
    }

    private static String capitalizeFirst(String str) {
        return Character.toUpperCase(str.charAt(0)) + str.substring(1);
    }

    private static boolean isBoolean(Class<?> type) {
        return (type == Boolean.class || type == Boolean.TYPE);
    }

    private static Object isUser(AccessibleObject member, Class<?> clazz) {
        QtPropertyUser user = member.getAnnotation(QtPropertyUser.class);

        if (user != null) {
            String value = user.value();

            if (value.equalsIgnoreCase("true")) {
                return Boolean.TRUE;
            } else if (value.equalsIgnoreCase("false")) {
                return Boolean.FALSE;
            } else try {
                Method m = clazz.getMethod(value);
                if (isBoolean(m.getReturnType()))
                    return m;
                else
                    throw new RuntimeException("Wrong return type of scriptable method '" + m.getName() + "'");
            } catch (Throwable t) {
                java.util.logging.Logger.getLogger("io.qt.internal").log(java.util.logging.Level.SEVERE, "", t);
            }
        }

        return Boolean.FALSE;
    }

    private static Boolean isRequired(AccessibleObject member, Class<?> clazz) {
        QtPropertyRequired required = member.getAnnotation(QtPropertyRequired.class);
        if (required != null) {
            return required.value();
        }
        return Boolean.FALSE;
    }

    private static Boolean isFinal(Method declaredMethod) {
        return Modifier.isFinal(declaredMethod.getModifiers());
    }

    private static Boolean isConstant(AccessibleObject member) {
        QtPropertyConstant isConstant = member.getAnnotation(QtPropertyConstant.class);
        if (isConstant != null) {
            return isConstant.value();
        }
        return Boolean.FALSE;
    }

    private static boolean isValidGetter(Method method) {
        return (method.getParameterCount() == 0
                && method.getReturnType() != Void.TYPE);
    }
    
    private static Class<?> getBoxedType(Class<?> type){
    	if(type.isPrimitive()) {
    		if(int.class==type) {
    			type = Integer.class;
    		}else if(byte.class==type) {
    			type = Byte.class;
    		}else if(short.class==type) {
    			type = Short.class;
    		}else if(long.class==type) {
    			type = Long.class;
    		}else if(double.class==type) {
    			type = Double.class;
    		}else if(float.class==type) {
    			type = Float.class;
    		}else if(boolean.class==type) {
    			type = Boolean.class;
    		}else if(char.class==type) {
    			type = Character.class;
    		}
    	}
    	return type;
    }

    /**
     * this method creates Qt5 meta object data from the submitted class.
     * It is based upon code of the moc tool.
     */
    @NativeAccess
    private static MetaData buildMetaData(Class<?> clazz) {
        try {
            if(clazz.isPrimitive()) {
                throw new RuntimeException("Cannot resolve meta object from primitive type");
            }
            else if(clazz.isArray()) {
            	throw new RuntimeException("Cannot resolve meta object from array type");
            }
            MetaData metaData = new MetaData();
            metaData.addStringData("Reserving the first string for QDynamicMetaObject identification.");
            List<String> intdataComments = /*new ArrayList<>();*/new AbstractList<String>() {
                @Override
                public boolean add(String e) { return false; }
                @Override
                public String get(int index) {return null;}
                @Override
                public int size() {return 0; }
            };
            final String classname = clazz.getName().replace(".", "::");
            
            Hashtable<String,String> classInfos = new Hashtable<String, String>();
            
            for(QtClassInfo info : clazz.getAnnotationsByType(QtClassInfo.class)) {
                classInfos.put(info.key(), info.value());
            }
            
            Map<Method, MethodFlags> methodFlags = new HashMap<>();
            TreeMap<String, Method> propertyReaders = new TreeMap<>();
            TreeMap<String, List<Method>> propertyWriters = new TreeMap<>();
            TreeMap<String, Object> propertyDesignableResolvers = new TreeMap<>();
            TreeMap<String, Object> propertyScriptableResolvers = new TreeMap<>();
            TreeMap<String, Object> propertyEditableResolvers = new TreeMap<>();
            TreeMap<String, Object> propertyStoredResolvers = new TreeMap<>();
            TreeMap<String, Object> propertyUserResolvers = new TreeMap<>();
            TreeMap<String, Boolean> propertyRequiredResolvers = new TreeMap<>();
            TreeMap<String, Boolean> propertyConstantResolvers = new TreeMap<>();
            TreeMap<String, Boolean> propertyFinalResolvers = new TreeMap<>();
                                                                                         
            TreeMap<String, Method> propertyResetters = new TreeMap<>();
            TreeMap<String, Field> propertyNotifies = new TreeMap<>();
            TreeMap<String, Method> propertyBindables = new TreeMap<>();
            TreeMap<String, Field> propertyMembers = new TreeMap<>();
            TreeMap<String, Field> propertyQPropertyFields = new TreeMap<>();
            TreeMap<String, Field> signals = new TreeMap<>();
            
            // First we get all enums actually declared in the class
            Hashtable<String, Class<?>> enums = new Hashtable<String, Class<?>>();
            queryEnums(clazz, enums);
            
            class ParameterInfo{
            	public ParameterInfo(int metaTypeId, String typeName) {
					super();
					this.type = null;
					this.metaTypeId = metaTypeId;
					this.typeName = typeName;
				}
            	public ParameterInfo(io.qt.core.QMetaType.Type type) {
					super();
					this.type = type;
					this.metaTypeId = 0;
					this.typeName = null;
				}
				final QMetaType.Type type;
            	final int metaTypeId;
            	final String typeName;
            }

            Set<String> addedMethodSignatures = new TreeSet<>();
            List<Boolean> signalIsClone = new ArrayList<>();
            List<List<ParameterInfo>> allSignalParameterInfos = new ArrayList<>();
//            cl.getEnclosingClass() != QInstanceMemberSignals.class
            boolean isQObject = QObject.class.isAssignableFrom(clazz);
//            if(QObject.class.isAssignableFrom(clazz)) 
            {
            	TreeSet<Field> declaredFields = new TreeSet<>((m1, m2)->{
                	return m1.getName().compareTo(m2.getName());
                });
            	declaredFields.addAll(Arrays.asList(clazz.getDeclaredFields()));
signalLoop:	    for (Field declaredField : declaredFields) {
					Class<?> signalClass = declaredField.getType();
	            	if(isQObjectSignalType(signalClass)) {
	            		if (!Modifier.isStatic(declaredField.getModifiers())) {
	            			if(!isQObject && signalClass.getEnclosingClass() == QObject.class)
	            				throw new QSignalDeclarationException(String.format("Declaration error at signal %1$s.%2$s: do not use QObject signals within non-QObjects.", clazz.getSimpleName(), declaredField.getName()));
		                    // If we can't convert all the types we don't list the signal
	            			List<Class<?>> emitParameterTypes = new ArrayList<>();
	            			List<SignalParameterType> signalTypes = new ArrayList<>(QtJambiSignals.resolveSignal(declaredField));
	                    	List<String> cppTypes = new ArrayList<>();
	                        List<ParameterInfo> signalParameterInfos = new ArrayList<>();
	                        for (int j = 0; j < signalTypes.size(); j++) {
	                        	emitParameterTypes.add(Object.class);
	                            QtJambiSignals.SignalParameterType signalType = signalTypes.get(j);
	                            QtMetaType metaTypeDecl = signalType.annotatedType!=null ? signalType.annotatedType.getAnnotation(QtMetaType.class) : null;
	                            int metaTypeId = 0;
	                            String typeName;
	                            if(metaTypeDecl!=null) {
	                				if(metaTypeDecl.id()!=0) {
	                					metaTypeId = metaTypeDecl.id();
	                					if(signalType.isPointer || signalType.isReference) {
	                						metaTypeId = registerRefMetaType(metaTypeId, signalType.isPointer, signalType.isReference);
	                					}
	                					typeName = new QMetaType(metaTypeId).name().toString();
	                				}else if(metaTypeDecl.type()!=QMetaType.Type.UnknownType){
	                					metaTypeId = metaTypeDecl.type().value();
	                					if(signalType.isPointer || signalType.isReference) {
	                						metaTypeId = registerRefMetaType(metaTypeId, signalType.isPointer, signalType.isReference);
	                					}
	                					typeName = new QMetaType(metaTypeId).name().toString();
	                				}else {
	            						if(metaTypeDecl.name().isEmpty())
	            							throw new IllegalArgumentException("Incomplete @QtMetaType declaration. Either use type, id or name to specify meta type.");
	                					typeName = metaTypeDecl.name();
	                					if(signalType.isPointer && !typeName.endsWith("*")) {
	                                        typeName += "*";
	                                    }
	                                    if(signalType.isReference) {
	                                    	if(typeName.endsWith("*")) {
	                                            typeName = typeName.substring(0, typeName.length()-2);
	                                        }
	                                        if(!typeName.endsWith("&")) {
	                                            typeName += "&";
	                                        }
	                                    }
	                				}
	                			}else{
	                				typeName = internalTypeNameOfClass(signalType.type, signalType.genericType);
	                				if(signalType.isPointer) {
	                                    if(!typeName.endsWith("*")) {
	                                        typeName += "*";
	                                    }
	                                }
	                                if(signalType.isReference) {
	                                    if(typeName.endsWith("*")) {
	                                        typeName = typeName.substring(0, typeName.length()-2);
	                                    }
	                                    if(!typeName.endsWith("&")) {
	                                        typeName += "&";
	                                    }
	                                }
	                			}
	                            QMetaType.Type type = metaType(typeName);
	                            if(type==QMetaType.Type.UnknownType || type==QMetaType.Type.User){
	                                if(metaTypeId==QMetaType.Type.UnknownType.value()) {
	                                	metaTypeId = QtJambiInternal.findMetaType(typeName);
	    	                            if(metaTypeId==QMetaType.Type.UnknownType.value() || !(signalType.genericType instanceof Class || new QMetaType(metaTypeId).name().toString().equals(typeName))) {
	    	                                metaTypeId = registerMetaType(signalType.type, signalType.genericType, null, signalType.isPointer, signalType.isReference);
	    	                            }
	    	                            if(metaTypeId!=QMetaType.Type.UnknownType.value())
	    	                                typeName = new QMetaType(metaTypeId).name().toString();
	    	                            else
	    	                            	continue signalLoop;
	                                }
	                                cppTypes.add(typeName);
	                                signalParameterInfos.add(new ParameterInfo(metaTypeId, typeName));
	                            }else{
	                                cppTypes.add(new QMetaType(type).name().toString());
	                                signalParameterInfos.add(new ParameterInfo(type));
	                            }
	                        }
	                        long methodId = findEmitMethodId(signalClass, emitParameterTypes);
	                        String methodSignature = String.format("%1$s(%2$s)", declaredField.getName(), String.join(", ", cppTypes));
	                        if(!addedMethodSignatures.contains(methodSignature) && methodId!=0) {
	                        	if (!Modifier.isFinal(declaredField.getModifiers())) {
		                    		if(!Boolean.getBoolean("qtjambi.allow-nonfinal-signals") && !Boolean.getBoolean("io.qt.allow-nonfinal-signals")) {
		                    			java.util.logging.Logger.getLogger("io.qt.internal").severe(String.format("Missing modifier 'final' at signal %1$s.%2$s. Specify JVM argument -Dqtjambi.allow-nonfinal-signals=true to disable this error.", clazz.getSimpleName(), declaredField.getName()));
		                    			throw new QSignalDeclarationException(String.format("Missing modifier 'final' at signal %1$s.%2$s.", clazz.getSimpleName(), declaredField.getName()));
		                    		}
		                    	}
			                    // Rules for resetters:
			                    // 1. Zero or one argument
			                    if(signalTypes.size() <= 1){
			                        PropertyAnnotation notify = PropertyAnnotation.notifyAnnotation(declaredField);
			
			                        if (notify != null) {
			                            propertyNotifies.put(notify.name(), declaredField);
			                        }
			                    }
	                        	addedMethodSignatures.add(methodSignature);
	                        	signalIsClone.add(Boolean.FALSE);
	                        	allSignalParameterInfos.add(new ArrayList<>(signalParameterInfos));
                        		metaData.signalInfos.add(new SignalInfo(declaredField, new ArrayList<>(signalTypes), signalClass, new int[signalTypes.size()], methodId));
                        		signals.put(declaredField.getName(), declaredField);
		                        Runnable addDefaultSignal = ()->{
		                        	signalTypes.remove(signalTypes.size()-1);
	                        		signalParameterInfos.remove(signalParameterInfos.size()-1);
	                        		cppTypes.remove(cppTypes.size()-1);
	                        		emitParameterTypes.remove(emitParameterTypes.size()-1);
		                        	long _methodId = findEmitMethodId(signalClass, emitParameterTypes);
	                        		String _methodSignature = String.format("%1$s(%2$s)", declaredField.getName(), String.join(", ", cppTypes));
	                        		if(!addedMethodSignatures.contains(_methodSignature) && _methodId!=0) {
	                        			addedMethodSignatures.add(_methodSignature);
	                        			signalIsClone.add(Boolean.TRUE);
	    	                        	allSignalParameterInfos.add(new ArrayList<>(signalParameterInfos));
	    	                        	metaData.signalInfos.add(new SignalInfo(declaredField, new ArrayList<>(signalTypes), signalClass, new int[signalTypes.size()], _methodId));
	                        		}
		                        };
		                        switch(signalTypes.size()) {
		                        case 9:
		                        	if(QMetaObject.Emitable8.class.isAssignableFrom(signalClass)) {
		                        		addDefaultSignal.run();
		                        	}else break;
		                        case 8:
		                        	if(QMetaObject.Emitable7.class.isAssignableFrom(signalClass)) {
		                        		addDefaultSignal.run();
		                        	}else break;
		                        case 7:
		                        	if(QMetaObject.Emitable6.class.isAssignableFrom(signalClass)) {
		                        		addDefaultSignal.run();
		                        	}else break;
		                        case 6:
		                        	if(QMetaObject.Emitable5.class.isAssignableFrom(signalClass)) {
		                        		addDefaultSignal.run();
		                        	}else break;
		                        case 5:
		                        	if(QMetaObject.Emitable4.class.isAssignableFrom(signalClass)) {
		                        		addDefaultSignal.run();
		                        	}else break;
	                        	case 4:
		                        	if(QMetaObject.Emitable3.class.isAssignableFrom(signalClass)) {
		                        		addDefaultSignal.run();
		                        	}else break;
	                        	case 3:
		                        	if(QMetaObject.Emitable2.class.isAssignableFrom(signalClass)) {
		                        		addDefaultSignal.run();
		                        	}else break;
	                        	case 2:
		                        	if(QMetaObject.Emitable1.class.isAssignableFrom(signalClass)) {
		                        		addDefaultSignal.run();
		                        	}else break;
	                        	case 1:
		                        	if(QMetaObject.Emitable0.class.isAssignableFrom(signalClass)) {
		                        		addDefaultSignal.run();
		                        	}else break;
		                        }
	                        }
	                	}else {
	                		throw new QSignalDeclarationException(String.format("Modifier 'static' not allowed for signal %1$s.%2$s. Use QStaticMemberSignals instead to declare a static signal.", clazz.getSimpleName(), declaredField.getName()));
	                	}
	            	}else if(isQObject && QtJambiSignals.AbstractMultiSignal.class.isAssignableFrom(signalClass) && QObject.class!=signalClass.getEnclosingClass()) {
	            		if(Modifier.isStatic(declaredField.getModifiers()))
	                		throw new QSignalDeclarationException(String.format("Modifier 'static' not allowed for signal %1$s.%2$s. Use QStaticMemberSignals instead to declare a static signal.", clazz.getSimpleName(), declaredField.getName()));
            			if(declaredField.getDeclaringClass()!=signalClass.getEnclosingClass())
            				throw new QSignalDeclarationException(String.format("Declaration error at signal %1$s.%2$s: Multi signal class has to be declared in the class using it.", clazz.getSimpleName(), declaredField.getName()));
            			if(!Modifier.isFinal(signalClass.getModifiers()))
            				throw new QSignalDeclarationException(String.format("Missing modifier 'final' at signal class %1$s.", signalClass.getTypeName()));
                    	if (!Modifier.isFinal(declaredField.getModifiers()))
                			throw new QSignalDeclarationException(String.format("Missing modifier 'final' at signal %1$s.%2$s.", clazz.getSimpleName(), declaredField.getName()));
                    	Map<List<Class<?>>,QtJambiSignals.EmitMethodInfo> emitMethods = QtJambiSignals.findEmitMethods(signalClass);
        				if(emitMethods.keySet().isEmpty())
        					throw new QSignalDeclarationException(String.format("Missing modifier emit methods at signal class %1$s.", signalClass.getTypeName()));
                        for (QtJambiSignals.EmitMethodInfo emitMethodInfo : emitMethods.values()) {
                        	if(emitMethodInfo.methodId==0)
                        		continue;
                        	List<SignalParameterType> signalTypes = emitMethodInfo.parameterTypes;
	                    	List<String> cppTypes = new ArrayList<>();
	                        List<ParameterInfo> signalParameterInfos = new ArrayList<>();
	                        List<Class<?>> signalClassTypes = new ArrayList<>();
	                        for (int j = 0; j < signalTypes.size(); j++) {
	                            QtJambiSignals.SignalParameterType signalType = signalTypes.get(j);
	                            signalClassTypes.add(signalType.type);
	                            QtMetaType metaTypeDecl = signalType.annotatedType==null ? null : signalType.annotatedType.getAnnotation(QtMetaType.class);
	                            int metaTypeId = 0;
	                            String typeName;
	                            if(metaTypeDecl!=null) {
	                				if(metaTypeDecl.id()!=0) {
	                					metaTypeId = metaTypeDecl.id();
	                					if(signalType.isPointer || signalType.isReference) {
	                						metaTypeId = registerRefMetaType(metaTypeId, signalType.isPointer, signalType.isReference);
	                					}
	                					typeName = new QMetaType(metaTypeId).name().toString();
	                				}else if(metaTypeDecl.type()!=QMetaType.Type.UnknownType){
	                					metaTypeId = metaTypeDecl.type().value();
	                					if(signalType.isPointer || signalType.isReference) {
	                						metaTypeId = registerRefMetaType(metaTypeId, signalType.isPointer, signalType.isReference);
	                					}
	                					typeName = new QMetaType(metaTypeId).name().toString();
	                				}else {
	            						if(metaTypeDecl.name().isEmpty())
	            							throw new IllegalArgumentException("Incomplete @QtMetaType declaration. Either use type, id or name to specify meta type.");
	                					typeName = metaTypeDecl.name();
	                					if(signalType.isPointer && !typeName.endsWith("*")) {
	                                        typeName += "*";
	                                    }
	                                    if(signalType.isReference) {
	                                    	if(typeName.endsWith("*")) {
	                                            typeName = typeName.substring(0, typeName.length()-2);
	                                        }
	                                        if(!typeName.endsWith("&")) {
	                                            typeName += "&";
	                                        }
	                                    }
	                				}
	                			}else{
	                				typeName = internalTypeNameOfClass(signalType.type, signalType.genericType);
	                				if(signalType.isPointer) {
	                                    if(!typeName.endsWith("*")) {
	                                        typeName += "*";
	                                    }
	                                }
	                                if(signalType.isReference) {
	                                    if(typeName.endsWith("*")) {
	                                        typeName = typeName.substring(0, typeName.length()-2);
	                                    }
	                                    if(!typeName.endsWith("&")) {
	                                        typeName += "&";
	                                    }
	                                }
	                			}
	                            QMetaType.Type type = metaType(typeName);
	                            if(type==QMetaType.Type.UnknownType || type==QMetaType.Type.User){
	                                if(metaTypeId==QMetaType.Type.UnknownType.value()) {
	                                	metaTypeId = QtJambiInternal.findMetaType(typeName);
	    	                            if(metaTypeId==QMetaType.Type.UnknownType.value() || !(signalType.genericType instanceof Class || new QMetaType(metaTypeId).name().toString().equals(typeName))) {
	    	                                metaTypeId = registerMetaType(signalType.type, signalType.genericType, null, signalType.isPointer, signalType.isReference);
	    	                            }
	    	                            if(metaTypeId!=QMetaType.Type.UnknownType.value())
	    	                                typeName = new QMetaType(metaTypeId).name().toString();
	    	                            else
	    	                            	continue signalLoop;
	                                }
	                                cppTypes.add(typeName);
	                                signalParameterInfos.add(new ParameterInfo(metaTypeId, typeName));
	                            }else{
	                                cppTypes.add(new QMetaType(type).name().toString());
	                                signalParameterInfos.add(new ParameterInfo(type));
	                            }
	                        }
	                        String methodSignature = String.format("%1$s(%2$s)", declaredField.getName(), String.join(", ", cppTypes));
	                        if(!addedMethodSignatures.contains(methodSignature)) {
	                        	addedMethodSignatures.add(methodSignature);
	                        	signalIsClone.add(Boolean.FALSE);
	                        	allSignalParameterInfos.add(new ArrayList<>(signalParameterInfos));
	                        	Class<?> _signalClass;
	                        	QtJambiSignals.SignalClasses signalClasses = QtJambiSignals.signalClasses(QObject.class);
                        		if(signalClasses==null)
                        			throw new QSignalInitializationException("Unable to resolve multi signal.");
	                        	if(Modifier.isPublic(emitMethodInfo.method.getModifiers())) {
            						_signalClass = signalClasses.getPublicSignal(emitMethodInfo.parameterTypes.size());
            					}else {
            						_signalClass = signalClasses.getPrivateSignal(emitMethodInfo.parameterTypes.size());
            					}
	                        	metaData.signalInfos.add(new SignalInfo(declaredField, new ArrayList<>(signalTypes), _signalClass, new int[signalTypes.size()], emitMethodInfo.methodId));
	                        	signals.put(declaredField.getName(), declaredField);
	                        }
            			}
	            	}else{
	            		PropertyAnnotation member = PropertyAnnotation.memberAnnotation(declaredField);
	            		if(member!=null) {
	            			if(member.enabled()) {
    	            			String property = member.name();
	            				if(isQObject && isValidQProperty(declaredField)) {
	    	                		propertyQPropertyFields.put(property, declaredField);
	    	                	}else {
	    	                		propertyMembers.put(property, declaredField);
	    	                	}
            					propertyDesignableResolvers.put(property, isDesignable(declaredField, clazz));
                                propertyScriptableResolvers.put(property, isScriptable(declaredField, clazz));
                                propertyEditableResolvers.put(property, isEditable(declaredField, clazz));
                                propertyStoredResolvers.put(property, isStored(declaredField, clazz));
                                propertyUserResolvers.put(property, isUser(declaredField, clazz));
                                propertyRequiredResolvers.put(property, isRequired(declaredField, clazz));
                                propertyConstantResolvers.put(property, isConstant(declaredField));
                                propertyFinalResolvers.put(property, true);
	            			}
	            		}else if(isQObject && isValidQProperty(declaredField)) {
	            			String property = declaredField.getName();
	                		propertyQPropertyFields.put(property, declaredField);
        					propertyDesignableResolvers.put(property, isDesignable(declaredField, clazz));
                            propertyScriptableResolvers.put(property, isScriptable(declaredField, clazz));
                            propertyEditableResolvers.put(property, isEditable(declaredField, clazz));
                            propertyStoredResolvers.put(property, isStored(declaredField, clazz));
                            propertyUserResolvers.put(property, isUser(declaredField, clazz));
                            propertyRequiredResolvers.put(property, isRequired(declaredField, clazz));
                            propertyConstantResolvers.put(property, isConstant(declaredField));
                            propertyFinalResolvers.put(property, true);
	                	}
	                }
	            }
            }
            
            List<List<ParameterInfo>> allConstructorParameterInfos = new ArrayList<>();
//			if(QObject.class.isAssignableFrom(clazz)) 
            {
            	TreeSet<Constructor<?>> declaredConstructors = new TreeSet<>((m1, m2)->{
                	return m1.toGenericString().compareTo(m2.toGenericString());
                });
                declaredConstructors.addAll(Arrays.asList(clazz.getDeclaredConstructors()));
cloop: 		    for(Constructor<?> constructor : declaredConstructors){
                    if(!constructor.isSynthetic() && constructor.isAnnotationPresent(QtInvokable.class)) {
                        Class<?>[] parameterTypes = constructor.getParameterTypes();
                        for (Class<?> parameterType : parameterTypes) {
                            if(parameterType==PrivateConstructorAccess.type()
                            		|| parameterType==DeclarativeConstructorAccess.type()) {
                                continue cloop;
                            }
                        }
                        
                    	List<String> cppTypes = new ArrayList<>();
                        List<ParameterInfo> constructorParameterInfos = new ArrayList<>();
                        Type[] genericParameterTypes = constructor.getGenericParameterTypes();
                        AnnotatedElement[] annotatedParameterTypes = null;
                        if(QtJambiInternal.useAnnotatedType) {
                        	annotatedParameterTypes = constructor.getAnnotatedParameterTypes();
                        }
                        for (int j = 0; j < parameterTypes.length; j++) {
                            boolean isPointer = false;
                            boolean isReference = false;
                            if(annotatedParameterTypes!=null && annotatedParameterTypes[j]!=null) {
	                            if(annotatedParameterTypes[j].isAnnotationPresent(QtPointerType.class)) {
	                            	isPointer = true;
	                            }
	                            QtReferenceType referenceType = annotatedParameterTypes[j].getAnnotation(QtReferenceType.class);
	                            if(referenceType!=null && !referenceType.isConst()) {
	                            	isReference = true;
	                            }
                            }
                            String typeName;
                            QtMetaType metaTypeDecl = annotatedParameterTypes==null || annotatedParameterTypes[j]==null ? null : annotatedParameterTypes[j].getAnnotation(QtMetaType.class);
                            int metaTypeId = 0;
                            if(metaTypeDecl!=null) {
                				if(metaTypeDecl.id()!=0) {
                					metaTypeId = metaTypeDecl.id();
                					if(isPointer || isReference) {
                						metaTypeId = registerRefMetaType(metaTypeId, isPointer, isReference);
                					}
                					typeName = new QMetaType(metaTypeId).name().toString();
                				}else if(metaTypeDecl.type()!=QMetaType.Type.UnknownType){
                					metaTypeId = metaTypeDecl.type().value();
                					if(isPointer || isReference) {
                						metaTypeId = registerRefMetaType(metaTypeId, isPointer, isReference);
                					}
                					typeName = new QMetaType(metaTypeId).name().toString();
                				}else {
            						if(metaTypeDecl.name().isEmpty())
            							throw new IllegalArgumentException("Incomplete @QtMetaType declaration. Either use type, id or name to specify meta type.");
                					typeName = metaTypeDecl.name();
                					if(isPointer && !typeName.endsWith("*")) {
                                        typeName += "*";
                                    }
                                    if(isReference) {
                                    	if(typeName.endsWith("*")) {
                                            typeName = typeName.substring(0, typeName.length()-2);
                                        }
                                        if(!typeName.endsWith("&")) {
                                            typeName += "&";
                                        }
                                    }
                				}
                			}else {
                				typeName = internalTypeNameOfClass(parameterTypes[j], genericParameterTypes[j]);
                				if(isPointer && !typeName.endsWith("*")) {
                                    typeName += "*";
                                }
                                if(isReference) {
                                	if(typeName.endsWith("*")) {
                                        typeName = typeName.substring(0, typeName.length()-2);
                                    }
                                    if(!typeName.endsWith("&")) {
                                        typeName += "&";
                                    }
                                }
                			}
                        	QMetaType.Type type = metaType(typeName);
                            if(type==QMetaType.Type.UnknownType || type==QMetaType.Type.User){
                                if(metaTypeId==QMetaType.Type.UnknownType.value()) {
    	                        	metaTypeId = QtJambiInternal.findMetaType(typeName);
    	                            if(metaTypeId==QMetaType.Type.UnknownType.value() || !(genericParameterTypes[j] instanceof Class || new QMetaType(metaTypeId).name().toString().equals(typeName))) {
    	                                metaTypeId = registerMetaType(parameterTypes[j], 
    	                                        genericParameterTypes[j],
    	                                        annotatedParameterTypes!=null ? annotatedParameterTypes[j] : null,
    	                                        isPointer,
    	                                        isReference);
    	                            }
    	                            if(metaTypeId!=QMetaType.Type.UnknownType.value())
    	                                typeName = new QMetaType(metaTypeId).name().toString();
    	                            else continue cloop;
                                }
                                cppTypes.add(typeName);
                                constructorParameterInfos.add(new ParameterInfo(metaTypeId, typeName));
                            }else{
                                cppTypes.add(new QMetaType(type).name().toString());
                                constructorParameterInfos.add(new ParameterInfo(type));
                            }
                        }
                        
                        String methodSignature = String.format("%1$s(%2$s)", constructor.getName(), String.join(", ", cppTypes));
                        if(!addedMethodSignatures.contains(methodSignature)) {
                        	addedMethodSignatures.add(methodSignature);
	                        allConstructorParameterInfos.add(constructorParameterInfos);
	                        metaData.constructors.add(constructor);
	                        metaData.constructorMetaTypes.add(new int[parameterTypes.length+1]);
	                        metaData.hasStaticMembers = true;
                        }
                    }
                }
            }
            
            List<List<ParameterInfo>> allMethodParameterInfos = new ArrayList<>();
            List<Method> possibleBindables = Collections.emptyList();
            TreeSet<Method> declaredMethods = new TreeSet<>((m1, m2)->{
            	return m1.toGenericString().compareTo(m2.toGenericString());
            });
            declaredMethods.addAll(Arrays.asList(clazz.getDeclaredMethods()));
            for (Method declaredMethod : declaredMethods) {
                if(declaredMethod.isSynthetic() 
                        || declaredMethod.isBridge()) {
                    continue;
                }
                if (
                        (
                                (
                                        QObject.class.isAssignableFrom(clazz)
                                        && !declaredMethod.isAnnotationPresent(QtUninvokable.class) 
                                        && !Modifier.isStatic(declaredMethod.getModifiers())
                                ) || (
                                        declaredMethod.isAnnotationPresent(QtInvokable.class) 
                                        && declaredMethod.getAnnotation(QtInvokable.class).value()
                                )
                        )
                        && !overridesGeneratedSlot(declaredMethod, clazz)
                    ) {
                	List<ParameterInfo> methodParameterInfos = new ArrayList<>();
                	boolean isPointer = false;
                    boolean isReference = false;
                    if(QtJambiInternal.useAnnotatedType
                    		&& (declaredMethod.getAnnotatedReturnType().isAnnotationPresent(QtPointerType.class)
                            		|| declaredMethod.isAnnotationPresent(QtPointerType.class))) {
                    	isPointer = true;
                    }
                    QtReferenceType referenceType = null;
                    if(QtJambiInternal.useAnnotatedType) {
                    	if(declaredMethod.getAnnotatedReturnType()!=null)
                    		referenceType = declaredMethod.getAnnotatedReturnType().getAnnotation(QtReferenceType.class);
                    }
                    if(referenceType==null)
                    	referenceType = declaredMethod.getAnnotation(QtReferenceType.class);
                    if(referenceType!=null && !referenceType.isConst()) {
                    	isReference = true;
                    }
                    QtMetaType metaTypeDecl = null;
                    if(QtJambiInternal.useAnnotatedType) {
                    	if(declaredMethod.getAnnotatedReturnType()!=null)
                    		metaTypeDecl = declaredMethod.getAnnotatedReturnType().getAnnotation(QtMetaType.class);
                    }
                    int metaTypeId = 0;
                    String typeName;
                    if(metaTypeDecl!=null) {
        				if(metaTypeDecl.id()!=0) {
        					metaTypeId = metaTypeDecl.id();
        					if(isPointer || isReference) {
        						metaTypeId = registerRefMetaType(metaTypeId, isPointer, isReference);
        					}
        					typeName = new QMetaType(metaTypeId).name().toString();
        				}else if(metaTypeDecl.type()!=QMetaType.Type.UnknownType){
        					metaTypeId = metaTypeDecl.type().value();
        					if(isPointer || isReference) {
        						metaTypeId = registerRefMetaType(metaTypeId, isPointer, isReference);
        					}
        					typeName = new QMetaType(metaTypeId).name().toString();
        				}else {
    						if(metaTypeDecl.name().isEmpty())
    							throw new IllegalArgumentException("Incomplete @QtMetaType declaration. Either use type, id or name to specify meta type.");
        					typeName = metaTypeDecl.name();
        					if(isPointer && !typeName.endsWith("*")) {
                                typeName += "*";
                            }
                            if(isReference) {
                            	if(typeName.endsWith("*")) {
                                    typeName = typeName.substring(0, typeName.length()-2);
                                }
                                if(!typeName.endsWith("&")) {
                                    typeName += "&";
                                }
                            }
        				}
        			}else {
        				typeName = internalTypeNameOfClass(declaredMethod.getReturnType(), declaredMethod.getGenericReturnType());
        				if(isPointer && !typeName.endsWith("*")) {
                            typeName += "*";
                        }
                        if(isReference) {
                        	if(typeName.endsWith("*")) {
                                typeName = typeName.substring(0, typeName.length()-2);
                            }
                            if(!typeName.endsWith("&")) {
                                typeName += "&";
                            }
                        }
        			}
                    QMetaType.Type type = metaType(typeName);
                    if(type==QMetaType.Type.UnknownType || type==QMetaType.Type.User){
                    	if(metaTypeId==QMetaType.Type.UnknownType.value()) {
	                    	metaTypeId = QtJambiInternal.findMetaType(typeName);
	                        if(metaTypeId==QMetaType.Type.UnknownType.value() || !(declaredMethod.getGenericReturnType() instanceof Class || new QMetaType(metaTypeId).name().toString().equals(typeName))) {
	                        	AnnotatedElement ae = null;
	                        	if(QtJambiInternal.useAnnotatedType)
	                        		ae = declaredMethod.getAnnotatedReturnType();
	                        	metaTypeId = registerMetaType(
	                                    declaredMethod.getReturnType(), 
	                                    declaredMethod.getGenericReturnType(), 
	                                    ae,
	                                    isPointer,
	                                    isReference);
	                        }
	                        if(metaTypeId!=QMetaType.Type.UnknownType.value())
	                            typeName = new QMetaType(metaTypeId).name().toString();
                    	}
                    	methodParameterInfos.add(new ParameterInfo(metaTypeId, typeName));
                    }else{
                    	methodParameterInfos.add(new ParameterInfo(type));
                    }
                    
                    List<String> cppTypes = new ArrayList<>();
                    Class<?>[] parameterTypes = declaredMethod.getParameterTypes();
                    Type[] genericParameterTypes = declaredMethod.getGenericParameterTypes();
                    AnnotatedElement[] annotatedParameterTypes = null;
                    if(QtJambiInternal.useAnnotatedType) {
                    	annotatedParameterTypes = declaredMethod.getAnnotatedParameterTypes();
                    }
                    for (int j = 0; j < parameterTypes.length; j++) {
                    	metaTypeId = 0;
                        isPointer = false;
                        isReference = false;
                        if(annotatedParameterTypes!=null && annotatedParameterTypes[j]!=null) {
	                        if(annotatedParameterTypes[j].isAnnotationPresent(QtPointerType.class)) {
	                        	isPointer = true;
	                        	
	                        }
	                        referenceType = annotatedParameterTypes[j].getAnnotation(QtReferenceType.class);
	                        if(referenceType!=null && !referenceType.isConst()) {
	                        	isReference = true;
	                        }
	                        metaTypeDecl = annotatedParameterTypes[j].getAnnotation(QtMetaType.class);
                        }
                    	if(metaTypeDecl!=null) {
            				if(metaTypeDecl.id()!=0) {
            					metaTypeId = metaTypeDecl.id();
            					if(isPointer || isReference) {
            						metaTypeId = registerRefMetaType(metaTypeId, isPointer, isReference);
            					}
            					typeName = new QMetaType(metaTypeId).name().toString();
            				}else if(metaTypeDecl.type()!=QMetaType.Type.UnknownType){
            					metaTypeId = metaTypeDecl.type().value();
            					if(isPointer || isReference) {
            						metaTypeId = registerRefMetaType(metaTypeId, isPointer, isReference);
            					}
            					typeName = new QMetaType(metaTypeId).name().toString();
            				}else {
        						if(metaTypeDecl.name().isEmpty())
        							throw new IllegalArgumentException("Incomplete @QtMetaType declaration. Either use type, id or name to specify meta type.");
            					typeName = metaTypeDecl.name();
            					if(isPointer && !typeName.endsWith("*")) {
                                    typeName += "*";
                                }
                                if(isReference) {
                                	if(typeName.endsWith("*")) {
                                        typeName = typeName.substring(0, typeName.length()-2);
                                    }
                                    if(!typeName.endsWith("&")) {
                                        typeName += "&";
                                    }
                                }
            				}
            			}else {
            				typeName = internalTypeNameOfClass(parameterTypes[j], genericParameterTypes[j]);
            				if(isPointer && !typeName.endsWith("*")) {
                                typeName += "*";
                            }
                            if(isReference) {
                            	if(typeName.endsWith("*")) {
                                    typeName = typeName.substring(0, typeName.length()-2);
                                }
                                if(!typeName.endsWith("&")) {
                                    typeName += "&";
                                }
                            }
            			}
                        type = metaType(typeName);
                        if(type==QMetaType.Type.UnknownType || type==QMetaType.Type.User){
                            if(metaTypeId==QMetaType.Type.UnknownType.value()) {
	                        	metaTypeId = QtJambiInternal.findMetaType(typeName);
	                            if(metaTypeId==QMetaType.Type.UnknownType.value() || !(genericParameterTypes[j] instanceof Class || new QMetaType(metaTypeId).name().toString().equals(typeName))) {
	                                metaTypeId = registerMetaType(parameterTypes[j], 
	                                        genericParameterTypes[j],
	                                        annotatedParameterTypes==null ? null : annotatedParameterTypes[j],
	                                        isPointer,
	                                        isReference);
	                            }
	                            if(metaTypeId!=QMetaType.Type.UnknownType.value())
	                                typeName = new QMetaType(metaTypeId).name().toString();
                            }
                            cppTypes.add(typeName);
                            methodParameterInfos.add(new ParameterInfo(metaTypeId, typeName));
                        }else{
                            cppTypes.add(new QMetaType(type).name().toString());
                        	methodParameterInfos.add(new ParameterInfo(type));
                        }
                    }
                    String methodSignature = String.format("%1$s(%2$s)", declaredMethod.getName(), String.join(", ", cppTypes));
                    if(!addedMethodSignatures.contains(methodSignature)) {
                    	allMethodParameterInfos.add(methodParameterInfos);
                    	metaData.methods.add(declaredMethod);
                        if(Modifier.isStatic(declaredMethod.getModifiers())){
                            methodFlags.put(declaredMethod, MethodFlags.MethodMethod);
                            metaData.hasStaticMembers = true;
                        }else{
                            if(!QObject.class.isAssignableFrom(clazz)) {
                                // we need to make sure that static_metacall is set
                                metaData.hasStaticMembers = true;
                            	methodFlags.put(declaredMethod, MethodFlags.MethodMethod);
                            }else {
                            	methodFlags.put(declaredMethod, MethodFlags.MethodSlot);
                            }
                        }
                        metaData.methodMetaTypes.add(new int[declaredMethod.getParameterCount()+1]);
                    }
                }
                
                final String declaredMethodName = declaredMethod.getName();

                // Rules for readers:
                // 1. Zero arguments
                // 2. Return something other than void
                // 3. We can convert the type
                PropertyAnnotation reader = PropertyAnnotation.readerAnnotation(declaredMethod);
                {

                    if ( 
                            (reader != null && reader.enabled())
                            && isValidGetter(declaredMethod)
                            && !internalTypeNameOfClass(declaredMethod.getReturnType(), declaredMethod.getGenericReturnType()).equals("")) {

                        String name = reader.name();
                        // If the return type of the property reader is not registered, then
                        // we need to register the owner class in the meta object (in which case
                        // it has to be a QObject)
                        Class<?> returnType = declaredMethod.getReturnType();

                        if ( (QFlags.class.isAssignableFrom(returnType) || Enum.class.isAssignableFrom(returnType))
                                && !isEnumAllowedForProperty(returnType) ) {
                            int type = registerMetaType(returnType);
                            if(type==QMetaType.Type.UnknownType.value()) {
                                System.err.println("Problem in property '" + name + "' in '" + clazz.getName()
                                                   + "' with return type '"+returnType.getName()
                                                   +"': Unable to register meta type.");
                                continue;
                            }
                        }
                        Field signalField = signals.get(name);
                        if(signalField!=null && QtJambiSignals.AbstractSignal.class.isAssignableFrom(returnType))
                        	continue;

                        propertyReaders.put(name, declaredMethod);
                        propertyDesignableResolvers.put(name, isDesignable(declaredMethod, clazz));
                                                                                                   
                        propertyScriptableResolvers.put(name, isScriptable(declaredMethod, clazz));
                        propertyEditableResolvers.put(name, isEditable(declaredMethod, clazz));
                        propertyStoredResolvers.put(name, isStored(declaredMethod, clazz));
                        propertyUserResolvers.put(name, isUser(declaredMethod, clazz));
                        propertyRequiredResolvers.put(name, isRequired(declaredMethod, clazz));
                        propertyConstantResolvers.put(name, isConstant(declaredMethod));
                        propertyFinalResolvers.put(name, isFinal(declaredMethod));
                    }
                }

                // Rules for writers:
                // 1. Takes exactly one argument
                // 2. Return void
                // 3. We can convert the type
                PropertyAnnotation writer = PropertyAnnotation.writerAnnotation(declaredMethod);
                {
                    if ( writer != null 
                            && writer.enabled()
                            && isValidSetter(declaredMethod)) {
                        propertyWriters.computeIfAbsent(writer.name(), QtJambiInternal.getArrayListFactory()).add(declaredMethod);
                    }
                }

                // Check naming convention by looking for setXxx patterns, but only if it hasn't already been
                // annotated as a writer
                if (QObject.class.isAssignableFrom(clazz)
                    && writer == null
                    && reader == null // reader can't be a writer, cause the signature doesn't match, just an optimization
                    && declaredMethodName.startsWith("set")
                    && declaredMethodName.length() > 3
                    && Character.isUpperCase(declaredMethodName.charAt(3))
                    && isValidSetter(declaredMethod)) {

                    Class<?> paramType = declaredMethod.getParameterTypes()[0];
                    String propertyName = Character.toLowerCase(declaredMethodName.charAt(3))
                                        + declaredMethodName.substring(4);

                    if (!propertyReaders.containsKey(propertyName)) {
                        // We need a reader as well, and the reader must not be annotated as disabled
                        // The reader can be called 'xxx', 'getXxx', 'isXxx' or 'hasXxx'
                        // (just booleans for the last two)
                        Method readerMethod = notBogus(getDeclaredMethod(clazz, propertyName, null), propertyName, paramType);
                        if (readerMethod == null)
                            readerMethod = notBogus(getDeclaredMethod(clazz, "get" + capitalizeFirst(propertyName), null), propertyName, paramType);
                        if (readerMethod == null && isBoolean(paramType))
                            readerMethod = notBogus(getDeclaredMethod(clazz, "is" + capitalizeFirst(propertyName), null), propertyName, paramType);
                        if (readerMethod == null && isBoolean(paramType))
                            readerMethod = notBogus(getDeclaredMethod(clazz, "has" + capitalizeFirst(propertyName), null), propertyName, paramType);

                        if (readerMethod != null) { // yay
                            reader = PropertyAnnotation.readerAnnotation(readerMethod);
                            if (reader == null) {
                                propertyReaders.put(propertyName, readerMethod);
                                propertyWriters.computeIfAbsent(propertyName, QtJambiInternal.getArrayListFactory()).add(declaredMethod);

                                propertyDesignableResolvers.put(propertyName, isDesignable(readerMethod, clazz));
                                propertyScriptableResolvers.put(propertyName, isScriptable(readerMethod, clazz));
                                propertyUserResolvers.put(propertyName, isUser(readerMethod, clazz));
                                propertyRequiredResolvers.put(propertyName, isRequired(readerMethod, clazz));
                            }
                        }
                    }
                }
                
                // Rules for notifys:
                // 1. No arguments
                // 2. Return void
                {
                    PropertyAnnotation resetter = PropertyAnnotation.resetterAnnotation(declaredMethod);
                    if (resetter != null
                        && declaredMethod.getParameterCount() == 0
                        && declaredMethod.getReturnType() == void.class) {
                        propertyResetters.put(resetter.name(), declaredMethod);
                    }
                }
                
                if(isValidBindable(declaredMethod)) {
	                PropertyAnnotation bindables = PropertyAnnotation.bindableAnnotation(declaredMethod);
                    if (bindables != null) {
                        propertyBindables.put(bindables.name(), declaredMethod);
                    }else{
                    	if(possibleBindables.isEmpty())
                    		possibleBindables = new ArrayList<>();
                    	possibleBindables.add(declaredMethod);
                    }
                }
            }
            
            for(Method possibleBindable : possibleBindables) {
            	String name = possibleBindable.getName();
            	if(name.startsWith("bindable") && name.length() > 8) {
            		name = PropertyAnnotation.removeAndLowercaseFirst(name, 8);
            		if (propertyReaders.containsKey(name)) {
            			propertyBindables.put(name, possibleBindable);
            		}
            	}
            }
            
            {
	            TreeMap<String, Field> _propertyQPropertyFields = new TreeMap<>(propertyQPropertyFields);
	            propertyQPropertyFields.clear();
	            for(Map.Entry<String, Field> entry : _propertyQPropertyFields.entrySet()) {
	            	String name = entry.getKey();
	        		if(name.endsWith("Prop")) {
	        			name = name.substring(0, name.length()-4);
	        		}else if(name.endsWith("Property")) {
	        			name = name.substring(0, name.length()-8);
	        		}
	        		PropertyAnnotation member;
	            	if(!propertyReaders.containsKey(entry.getKey()) 
	            			&& !propertyReaders.containsKey(name)
	            			&& !Modifier.isStatic(entry.getValue().getModifiers())
	            			&& Modifier.isFinal(entry.getValue().getModifiers())
	            			&& (Modifier.isPublic(entry.getValue().getModifiers())
	            					|| ((member = PropertyAnnotation.memberAnnotation(entry.getValue()))!=null && member.enabled()))) {
	            		propertyReaders.put(name, null);
	        			propertyQPropertyFields.put(name, entry.getValue());
	            	}
	            }
            }
            for(String prop : propertyMembers.keySet()) {
            	if(!propertyReaders.containsKey(prop)) {
            		propertyReaders.put(prop, null);
            	}
            }
            
            for(String property : propertyReaders.keySet()) {
            	if(propertyNotifies.get(property)==null) {
            		for(SignalInfo signalInfo : metaData.signalInfos) {
            			if(signalInfo.field.getName().equals(property+"Changed")) {
                			if(signalInfo.signalTypes.isEmpty()) {
                				propertyNotifies.put(property, signalInfo.field);
                			}else {
                				if(propertyReaders.get(property)!=null) {
                					if(signalInfo.signalTypes.get(0).type.isAssignableFrom(getBoxedType(propertyReaders.get(property).getReturnType()))) {
                        				propertyNotifies.put(property, signalInfo.field);
                        			}
                    			}else if(propertyMembers.get(property)!=null) {
                    				Field propertyField = propertyMembers.get(property);
                    				if(isValidQProperty(propertyField)) {
                    					MetaObjectTools.QPropertyTypeInfo pinfo = getQPropertyTypeInfo(propertyField);
                    					if(signalInfo.signalTypes.get(0).type.isAssignableFrom(getBoxedType(pinfo.propertyType))) {
                            				propertyNotifies.put(property, signalInfo.field);
                            			}
                    				}else if(signalInfo.signalTypes.get(0).type.isAssignableFrom(getBoxedType(propertyField.getType()))) {
                        				propertyNotifies.put(property, signalInfo.field);
                        			}
                    			}else if(propertyQPropertyFields.get(property)!=null) {
                    				MetaObjectTools.QPropertyTypeInfo pinfo = getQPropertyTypeInfo(propertyQPropertyFields.get(property));
                					if(signalInfo.signalTypes.get(0).type.isAssignableFrom(getBoxedType(pinfo.propertyType))) {
                        				propertyNotifies.put(property, signalInfo.field);
                        			}
                    			}
                			}
                			break;
                		}
            		}
            	}
            }
            
            int flagsIndex = 0;
            {
                // Until 4.7.x QtJambi used revision=1 however due to a change in the way
                //  4.7.x works some features of QtJambi stopped working.
                // revision 1         = MO_HEADER_LEN=10
                // revision 2 (4.5.x) = MO_HEADER_LEN=12 (added: constructorCount, constructorData)
                // revision 3         = MO_HEADER_LEN=13 (added: flags)
                // revision 4 (4.6.x) = MO_HEADER_LEN=14 (added: signalCount)
                // revision 5 (4.7.x) = MO_HEADER_LEN=14 (normalization)
                // revision 6 (4.8.x) = MO_HEADER_LEN=14 (added support for qt_static_metacall)
                // revision 7 (5.0.x) = MO_HEADER_LEN=14 (Qt5 to break backwards compatibility)
                // The format is compatible to share the same encoding code
                //  then we can change the revision to suit the Qt
                /// implementation we are working with.

                final int MO_HEADER_LEN = 14;  // header size        	
                // revision
                metaData.metaData.add(resolveMetaDataRevision());		intdataComments.add("revision");
                // classname
                metaData.metaData.add(metaData.addStringData(classname));		intdataComments.add("className");
                // classinfo
                metaData.metaData.add(classInfos.size());		intdataComments.add("classInfoCount");
                metaData.metaData.add(classInfos.isEmpty() ? 0 : MO_HEADER_LEN);		intdataComments.add("classInfoData");
                
                // methods
                int methodCount = metaData.signalInfos.size() + metaData.methods.size();
                metaData.metaData.add(methodCount);		intdataComments.add("methodCount");
                final int METHOD_METADATA_INDEX = metaData.metaData.size();
                metaData.metaData.add(0);		intdataComments.add("methodData");
                
                // properties
                metaData.metaData.add(propertyReaders.size());		intdataComments.add("propertyCount");
                final int PROPERTY_METADATA_INDEX = metaData.metaData.size();
                metaData.metaData.add(0);		intdataComments.add("propertyData");
                
                // enums/sets
                metaData.metaData.add(enums.size());		intdataComments.add("enumeratorCount");
                final int ENUM_METADATA_INDEX = metaData.metaData.size();
                metaData.metaData.add(0);		intdataComments.add("enumeratorData");
                
                // constructors
                metaData.metaData.add(!metaData.constructors.isEmpty() ? metaData.constructors.size() : 0);		intdataComments.add("constructorCount");
                final int CONSTRUCTOR_METADATA_INDEX = metaData.metaData.size();
                metaData.metaData.add(0);		intdataComments.add("constructorData");
                
                // flags
                flagsIndex = metaData.metaData.size();
                metaData.metaData.add(0);		intdataComments.add("flags");
                
                // signalCount
                metaData.metaData.add(metaData.signalInfos.size());		intdataComments.add("signalCount");
                
                //
                // Build classinfo array
                //
                for(Map.Entry<String,String> entry : classInfos.entrySet()){
                    // classinfo: key, value
                    metaData.metaData.add(metaData.addStringData(entry.getKey()));		intdataComments.add("classinfo: key");
                    metaData.metaData.add(metaData.addStringData(entry.getValue()));		intdataComments.add("classinfo: value");
                }
                
                HashMap<Object,Integer> paramIndexOfMethods = new HashMap<Object,Integer>();
                HashMap<Field,Integer> signalIndexes = new HashMap<>();
                
                //
                // Build signals array first, otherwise the signal indices would be wrong
                //
                if(metaData.signalInfos.size() + metaData.methods.size() > 0){

                    metaData.metaData.set(METHOD_METADATA_INDEX, metaData.metaData.size());
                    
                    for (int i = 0; i < metaData.signalInfos.size(); ++i) {
                        SignalInfo signalInfo = metaData.signalInfos.get(i);
                        if(!signalIndexes.containsKey(signalInfo.field))
                        	signalIndexes.put(signalInfo.field, i);
                        MethodAttributes flags = MethodFlags.MethodSignal.asFlags();
                        if (Modifier.isPrivate(signalInfo.field.getModifiers()))
                            flags.set(MethodFlags.AccessPrivate);
                        else if (Modifier.isPublic(signalInfo.field.getModifiers()))
                            flags.set(MethodFlags.AccessPublic);
                        else
                            flags.set(MethodFlags.AccessProtected);
                        
                        if (signalInfo.field.isAnnotationPresent(QtInvokable.class))
                            flags.set(MethodFlags.MethodScriptable);
                        if(Boolean.TRUE.equals(signalIsClone.get(i)))
                        	flags.set(MethodFlags.MethodCloned);
                        int argc = signalInfo.signalTypes.size();
                        
                        // signals: name, argc, parameters, tag, flags, initial metatype offsets
                        metaData.metaData.add(metaData.addStringData(signalInfo.field.getName()));		intdataComments.add("signal["+i+"]: name");
                        metaData.metaData.add(argc);		intdataComments.add("signal["+i+"]: argc");
                    	paramIndexOfMethods.put(new QPair<>(signalInfo.field, argc), metaData.metaData.size());
                        metaData.metaData.add(0);		intdataComments.add("signal["+i+"]: parameters");
                        metaData.metaData.add(metaData.addStringData(""));		intdataComments.add("signal["+i+"]: tag");
                        metaData.metaData.add(flags.value());		intdataComments.add("signal["+i+"]: flags");
                        if(QtJambiInternal.majorVersion()>5) {
                            metaData.metaData.add(0);		intdataComments.add("signal["+i+"]: initial metatype offsets");
                        }
                    }
                    
                    //
                    // Build method array
                    //
                    for (int i = 0; i < metaData.methods.size(); i++) {
                        Method method = metaData.methods.get(i);
                        MethodAttributes flags = methodFlags.get(method).asFlags();
                        if (Modifier.isPrivate(method.getModifiers()))
                            flags.set(MethodFlags.AccessPrivate);
                        else if (Modifier.isPublic(method.getModifiers()))
                            flags.set(MethodFlags.AccessPublic);
                        else
                            flags.set(MethodFlags.AccessProtected);
                        
                        if (!method.isAnnotationPresent(QtInvokable.class) || method.getAnnotation(QtInvokable.class).value())
                            flags.set(MethodFlags.MethodScriptable);
                        int argc = method.getParameterTypes().length;
                        
                        // slots: name, argc, parameters, tag, flags, initial metatype offsets
                        metaData.metaData.add(metaData.addStringData(method.getName()));
                        intdataComments.add("slot["+i+"]: name");
                        metaData.metaData.add(argc);
                        intdataComments.add("slot["+i+"]: argc");
                        paramIndexOfMethods.put(method, metaData.metaData.size());
                        metaData.metaData.add(0);
                        intdataComments.add("slot["+i+"]: parameters");
                        metaData.metaData.add(metaData.addStringData(""));
                        intdataComments.add("slot["+i+"]: tag");
                        metaData.metaData.add(flags.value());
                        intdataComments.add("slot["+i+"]: flags");
                        if(QtJambiInternal.majorVersion()>5) {
                            metaData.metaData.add(0);		intdataComments.add("slot["+i+"]: initial metatype offsets");
                        }
                    }
                }
                
                //
                // Build method parameters array
                //
                for(int i=0; i<propertyReaders.size(); ++i) {
                    metaData.metaTypes.add(0);
                }
                
                for (int i = 0; i < metaData.signalInfos.size(); ++i) {
                	SignalInfo signalInfo = metaData.signalInfos.get(i);
                	List<ParameterInfo> signalParameterInfos = allSignalParameterInfos.get(i);
                    // signals: parameters
                    int METHOD_PARAMETER_INDEX = paramIndexOfMethods.get(new QPair<>(signalInfo.field, signalInfo.signalMetaTypes.length));
                    metaData.metaData.set(METHOD_PARAMETER_INDEX, metaData.metaData.size());
                    if(QtJambiInternal.majorVersion()>5) {
                        metaData.metaData.set(METHOD_PARAMETER_INDEX+3, metaData.metaTypes.size());
                    }
                    metaData.metaData.add(QMetaType.Type.Void.value());		intdataComments.add("signal["+i+"].returnType");
                    metaData.metaTypes.add(QMetaType.Type.Void.value());
                    for (int j = 0; j < signalParameterInfos.size(); j++) {
                    	ParameterInfo info = signalParameterInfos.get(j);
                        if(info.type==null){
                        	signalInfo.signalMetaTypes[j] = info.metaTypeId;
                            metaData.metaData.add(0x80000000 | metaData.addStringData(info.typeName));
                            metaData.metaTypes.add(info.metaTypeId);
                        }else{
                        	signalInfo.signalMetaTypes[j] = info.type.value();
                        	metaData.metaData.add(info.type.value());
                            metaData.metaTypes.add(info.type.value());
                        }
                        intdataComments.add("signal["+i+"]: parameter["+j+"].arg");
                    }
                    for (int j = 0; j < signalParameterInfos.size(); j++) {
                        metaData.metaData.add(metaData.addStringData("arg__"+(j+1)));		intdataComments.add("signal["+i+"]: parameter["+j+"].argName");
                    }
                }
                
                //
                // Build constructors array
                //
                
                if(!metaData.constructors.isEmpty()){
                    metaData.metaData.set(CONSTRUCTOR_METADATA_INDEX, metaData.metaData.size());
                    for (int i = 0; i < metaData.constructors.size(); i++) {
                        Constructor<?> constructor = metaData.constructors.get(i);
                        MethodAttributes flags = MethodFlags.MethodConstructor.asFlags();
                        if (Modifier.isPrivate(constructor.getModifiers()))
                            flags.set(MethodFlags.AccessPrivate);
                        else if (Modifier.isPublic(constructor.getModifiers()))
                            flags.set(MethodFlags.AccessPublic);
                        else
                            flags.set(MethodFlags.AccessProtected);
                        
                        if (constructor.isAnnotationPresent(QtInvokable.class) && constructor.getAnnotation(QtInvokable.class).value())
                            flags.set(MethodFlags.MethodScriptable);
                        int argc = constructor.getParameterTypes().length;
                        
                        // constructors: name, argc, parameters, tag, flags
                        String className = constructor.getDeclaringClass().getName();
                        if(className.contains(".")){
                            className = className.substring(className.lastIndexOf('.')+1);
                        }
                        metaData.metaData.add(metaData.addStringData(className));		intdataComments.add("constructor["+i+"]: name");
                        metaData.metaData.add(argc);		intdataComments.add("constructor["+i+"]: argc");
                        paramIndexOfMethods.put(constructor, metaData.metaData.size());
                        metaData.metaData.add(0);		intdataComments.add("constructor["+i+"]: parameters");
                        metaData.metaData.add(metaData.addStringData(""));		intdataComments.add("constructor["+i+"]: tag");
                        metaData.metaData.add(flags.value());		intdataComments.add("constructor["+i+"]: flags");
                        if(QtJambiInternal.majorVersion()>5) {
                            metaData.metaData.add(0);		intdataComments.add("slot["+i+"]: initial metatype offsets");
                        }
                    }
                }
                
                for (int i = 0; i < metaData.methods.size(); i++) {
                    Method method = metaData.methods.get(i);
                    int[] metaTypes = metaData.methodMetaTypes.get(i);
                    List<ParameterInfo> methodParameterInfos = allMethodParameterInfos.get(i);
                    // slot/method: parameters
                    int METHOD_PARAMETER_INDEX = paramIndexOfMethods.get(method);
                    metaData.metaData.set(METHOD_PARAMETER_INDEX, metaData.metaData.size());
                    if(QtJambiInternal.majorVersion()>5) {
                        metaData.metaData.set(METHOD_PARAMETER_INDEX+3, metaData.metaTypes.size());
                    }
                    ParameterInfo info = methodParameterInfos.get(0);
                    if(info.type==null){
                        metaData.metaData.add(0x80000000 | metaData.addStringData(info.typeName));
                        metaData.metaTypes.add(info.metaTypeId);
                        metaTypes[0] = info.metaTypeId;
                    }else{
                        metaData.metaData.add(info.type.value());
                        metaData.metaTypes.add(info.type.value());
                        metaTypes[0] = info.type.value();
                    }
                    intdataComments.add("slot["+i+"].returnType");
                    for (int j = 1; j < methodParameterInfos.size(); j++) {
                    	info = methodParameterInfos.get(j);
                        if(info.type==null){
                            metaData.metaData.add(0x80000000 | metaData.addStringData(info.typeName));
                            metaData.metaTypes.add(info.metaTypeId);
                            metaTypes[j] = info.metaTypeId;
                        }else{
                            metaData.metaData.add(info.type.value());
                            metaData.metaTypes.add(info.type.value());
                            metaTypes[j] = info.type.value();
                        }
                        intdataComments.add("slot["+i+"]: parameter["+(j-1)+"].arg");
                    }
                    Parameter[] parameters = method.getParameters();
                    for (int j = 0; j < parameters.length; j++) {
                        if(parameters[j].isNamePresent()) {
                            metaData.metaData.add(metaData.addStringData(parameters[j].getName()));
                        }else {
                            metaData.metaData.add(metaData.addStringData("arg__"+(j+1)));
                        }
                        intdataComments.add("slot["+i+"]: parameter["+j+"].argName");
                    }
                }
                
                for (int i = 0; i < metaData.constructors.size(); i++) {
                    Constructor<?> constructor = metaData.constructors.get(i);
                    List<ParameterInfo> constructorParameterInfos = allConstructorParameterInfos.get(i);
                    int[] metaTypes = metaData.constructorMetaTypes.get(i);
                    metaTypes[0] = QMetaType.Type.Void.value();
                    // constructors: parameters
                    int METHOD_PARAMETER_INDEX = paramIndexOfMethods.get(constructor);
                    metaData.metaData.set(METHOD_PARAMETER_INDEX, metaData.metaData.size());
                    if(QtJambiInternal.majorVersion()>5) {
                        metaData.metaData.set(METHOD_PARAMETER_INDEX+3, metaData.metaTypes.size());
                    }
                    metaData.metaData.add(0x80000000 | metaData.addStringData(""));
                    intdataComments.add("constructor["+i+"].returnType");
                    for (int j = 0; j < constructorParameterInfos.size(); j++) {
                    	ParameterInfo info = constructorParameterInfos.get(j);
                        if(info.type==null){
                            metaData.metaData.add(0x80000000 | metaData.addStringData(info.typeName));
                            metaData.metaTypes.add(info.metaTypeId);
                            metaTypes[j+1] = info.metaTypeId;
                        }else{
                            metaData.metaData.add(info.type.value());
                            metaData.metaTypes.add(info.type.value());
                            metaTypes[j+1] = info.type.value();
                        }
                        intdataComments.add("constructor["+i+"]: parameter["+(j)+"].arg");
                    }
                    Parameter[] parameters = constructor.getParameters();
                    for (int j = 0; j < parameters.length; j++) {
                        if(parameters[j].isNamePresent()) {
                            metaData.metaData.add(metaData.addStringData(parameters[j].getName()));
                        }else {
                            metaData.metaData.add(metaData.addStringData("arg__"+(j+1)));
                        }
                        intdataComments.add("constructor["+i+"]: parameter["+(j)+"].argName");
                    }
                }
                
                //
                // Build property array
                //
                int metaObjectFlags = 0;
                
                if(!propertyReaders.isEmpty()){
                    if(!QObject.class.isAssignableFrom(clazz)) {
                        metaObjectFlags |= PropertyAccessInStaticMetaCall.value();
                    }
                    metaData.metaData.set(PROPERTY_METADATA_INDEX, metaData.metaData.size());
                    int i=0;
                    for (String propertyName : propertyReaders.keySet()) {
                        Method reader = propertyReaders.get(propertyName);
                        Field qPropertyField = propertyQPropertyFields.get(propertyName);
                        Field propertyMemberField = propertyMembers.get(propertyName);
                        Method writer = null;
                        List<Method> writers = propertyWriters.get(propertyName);
                        Class<?> propertyType;
                        Type genericPropertyType;
                        AnnotatedElement annotatedPropertyType = null;
                        boolean isPointer;
                        boolean isReference;
                        boolean isMemberWritable = false;
                        boolean isMemberReadable = false;
                        boolean isMemberBindable = false;
                        QtMetaType metaTypeDecl;
                        if(reader!=null) {
                        	propertyType = reader.getReturnType();
                        	genericPropertyType = reader.getGenericReturnType();
                        	if(QtJambiInternal.useAnnotatedType) {
                        		annotatedPropertyType = reader.getAnnotatedReturnType();
                        	}
                        	isPointer = reader.isAnnotationPresent(QtPointerType.class)
                                    || (annotatedPropertyType!=null && annotatedPropertyType.isAnnotationPresent(QtPointerType.class));
                        	QtReferenceType referenceType = reader.getAnnotation(QtReferenceType.class);
                        	if(referenceType==null && annotatedPropertyType!=null)
                        		referenceType = annotatedPropertyType.getAnnotation(QtReferenceType.class);
                        	isReference = referenceType!=null && !referenceType.isConst();
                        	metaTypeDecl = annotatedPropertyType==null ? null : annotatedPropertyType.getAnnotation(QtMetaType.class);
                        }else if(propertyMemberField!=null) {
                        	if(isValidQProperty(propertyMemberField)) {
                        		qPropertyField = propertyMemberField;
                        		propertyMemberField = null;
                        		QPropertyTypeInfo info = getQPropertyTypeInfo(qPropertyField);
                            	if(info==null)
                            		continue;
                            	propertyType = info.propertyType;
                            	genericPropertyType = info.genericPropertyType;
                            	annotatedPropertyType = info.annotatedPropertyType;
                            	isPointer = info.isPointer;
                            	isReference = info.isReference;
                            	isMemberWritable = info.isWritable;
                            	isMemberReadable = true;
                            	isMemberBindable = true;
                            	if(info.annotatedPropertyType!=null)
                            		metaTypeDecl = info.annotatedPropertyType.getAnnotation(QtMetaType.class);
                            	else
                            		metaTypeDecl = null;
                        	}else {
                            	propertyType = propertyMemberField.getType();
                            	genericPropertyType = propertyMemberField.getGenericType();
                            	if(QtJambiInternal.useAnnotatedType) {
                            		annotatedPropertyType = propertyMemberField.getAnnotatedType();
                            	}
                            	isPointer = propertyMemberField.isAnnotationPresent(QtPointerType.class)
                                        || (annotatedPropertyType!=null && annotatedPropertyType.isAnnotationPresent(QtPointerType.class));
                            	QtReferenceType referenceType = propertyMemberField.getAnnotation(QtReferenceType.class);
                            	if(referenceType==null && annotatedPropertyType!=null)
                            		referenceType = annotatedPropertyType.getAnnotation(QtReferenceType.class);
                            	isReference = referenceType!=null && !referenceType.isConst();
                            	isMemberWritable = !Modifier.isFinal(propertyMemberField.getModifiers());
                            	isMemberReadable = true;
                            	metaTypeDecl = annotatedPropertyType!=null ? annotatedPropertyType.getAnnotation(QtMetaType.class) : null;
                        	}
                        }else if(qPropertyField!=null){
                        	QPropertyTypeInfo info = getQPropertyTypeInfo(qPropertyField);
                        	if(info==null)
                        		continue;
                        	propertyType = info.propertyType;
                        	genericPropertyType = info.genericPropertyType;
                        	annotatedPropertyType = info.annotatedPropertyType;
                        	isPointer = info.isPointer;
                        	isReference = info.isReference;
                        	isMemberWritable = info.isWritable;
                        	isMemberReadable = true;
                        	isMemberBindable = true;
                        	if(info.annotatedPropertyType!=null)
                        		metaTypeDecl = info.annotatedPropertyType.getAnnotation(QtMetaType.class);
                        	else
                        		metaTypeDecl = null;
                        }else {
                        	propertyType = null;
                        	genericPropertyType = null;
                        	annotatedPropertyType = null;
                        	isPointer = false;
                        	isReference = false;
                        	metaTypeDecl = null;
                        }
                        if(propertyType!=null) {
	                        if(writers!=null) {
	                        	for (Method w : writers) {
									if(w.getParameterCount()==1 && propertyType.isAssignableFrom(w.getParameterTypes()[0])) {
										writer = w;
										break;
									}
								}
	                        	if (!writers.isEmpty() && writer == null) {
	                        		writer = writers.get(0);
	                        	}
	                            if (writer != null && !propertyType.isAssignableFrom(writer.getParameterTypes()[0])) {
	                                Logger.getLogger("io.qt.internal").warning("Writer for property '"
	                                        + clazz.getName() + "::" + propertyName + "' takes a type (" + writer.getParameterTypes()[0].getName() + ") which is incompatible with reader's return type (" + propertyType.getName() + ").");
	                                writer = null;
	                            }
	                        }
                        }else {
                        	if(writers!=null && !writers.isEmpty()) {
                        		writer = writers.get(0);
                        		if(writer!=null) {
                        			propertyType = writer.getParameterTypes()[0];
                        			genericPropertyType = writer.getGenericParameterTypes()[0];
                        			if(QtJambiInternal.useAnnotatedType) {
                        				isPointer = writer.getAnnotatedParameterTypes()[0].isAnnotationPresent(QtPointerType.class);
                        				QtReferenceType referenceType = writer.getAnnotatedParameterTypes()[0].getAnnotation(QtReferenceType.class);
	                                	isReference = referenceType!=null && !referenceType.isConst();
	                                	metaTypeDecl = writer.getAnnotatedParameterTypes()[0].getAnnotation(QtMetaType.class);
                        			}
                        		}else {
                        			continue;
                        		}
                        	}
                        }
                        Method resetter = propertyResetters.get(propertyName);
                        Field notify = propertyNotifies.get(propertyName);
                        Method bindable = propertyBindables.get(propertyName);
                        Object designableVariant = propertyDesignableResolvers.get(propertyName);
                        Object scriptableVariant = propertyScriptableResolvers.get(propertyName);
                        Object editableVariant = propertyEditableResolvers.get(propertyName);
                        Object storedVariant = propertyStoredResolvers.get(propertyName);
                        Object userVariant = propertyUserResolvers.get(propertyName);
                        Boolean requiredVariant = propertyRequiredResolvers.get(propertyName);
                        Boolean constantVariant = propertyConstantResolvers.get(propertyName);
                        Boolean finalVariant = propertyFinalResolvers.get(propertyName);

                        PropertyAttributes flags = PropertyFlags.Invalid.asFlags();
                        // Type (need to special case flags and enums)
                        int metaTypeId = 0;
                        String typeName;
                        if(metaTypeDecl!=null) {
            				if(metaTypeDecl.id()!=0) {
            					metaTypeId = metaTypeDecl.id();
            					if(isPointer || isReference) {
            						metaTypeId = registerRefMetaType(metaTypeId, isPointer, isReference);
            					}
            					typeName = new QMetaType(metaTypeId).name().toString();
            				}else if(metaTypeDecl.type()!=QMetaType.Type.UnknownType){
            					metaTypeId = metaTypeDecl.type().value();
            					if(isPointer || isReference) {
            						metaTypeId = registerRefMetaType(metaTypeId, isPointer, isReference);
            					}
            					typeName = new QMetaType(metaTypeId).name().toString();
            				}else {
        						if(metaTypeDecl.name().isEmpty())
        							throw new IllegalArgumentException("Incomplete @QtMetaType declaration. Either use type, id or name to specify meta type.");
            					typeName = metaTypeDecl.name();
            					if(isPointer && !typeName.endsWith("*")) {
                                    typeName += "*";
                                }
                                if(isReference) {
                                	if(typeName.endsWith("*")) {
                                        typeName = typeName.substring(0, typeName.length()-2);
                                    }
                                    if(!typeName.endsWith("&")) {
                                        typeName += "&";
                                    }
                                }
            				}
            			}else{
            				typeName = internalTypeNameOfClass(propertyType, genericPropertyType);
            				if(isPointer) {
                                if(!typeName.endsWith("*")) {
                                    typeName += "*";
                                }
                            }
                            if(isReference) {
                                if(typeName.endsWith("*")) {
                                    typeName = typeName.substring(0, typeName.length()-2);
                                }
                                if(!typeName.endsWith("&")) {
                                    typeName += "&";
                                }
                            }
            			}
                        
                        if (!isBuiltinType(typeName))
                            flags.set(PropertyFlags.EnumOrFlag);
                        if (writer!=null){
                            flags.set(PropertyFlags.Writable);
                            String s = "set";
                            s += propertyName.toUpperCase().charAt(0);
                            s += propertyName.substring(1);
                            if (s.equals(writer.getName()))
                                flags.set(PropertyFlags.StdCppSet);
                        }else if(isMemberWritable)
                        	flags.set(PropertyFlags.Writable);
                        if (reader!=null || isMemberReadable)
                            flags.set(PropertyFlags.Readable);
                        if (resetter!=null)
                            flags.set(PropertyFlags.Resettable);
                        if ((bindable!=null || isMemberBindable) && Bindable!=null)
                            flags.set(Bindable);
                        
                        if (designableVariant instanceof Boolean) {
                            if ((Boolean) designableVariant)
                                flags.set(PropertyFlags.Designable);
                            metaData.propertyDesignableResolvers.add(null);
                        } else if (designableVariant instanceof Method) {
                            metaData.propertyDesignableResolvers.add((Method) designableVariant);
                            flags.set(ResolveDesignable);
                        }else {
                            metaData.propertyDesignableResolvers.add(null);
                        }
                        
                        if (scriptableVariant instanceof Boolean) {
                            if ((Boolean) scriptableVariant)
                                flags.set(PropertyFlags.Scriptable);
                            metaData.propertyScriptableResolvers.add(null);
                        } else if (scriptableVariant instanceof Method) {
                            flags.set(ResolveScriptable);
                            metaData.propertyScriptableResolvers.add((Method) scriptableVariant);
                        }else {
                            metaData.propertyScriptableResolvers.add(null);
                        }
                        
                        if (editableVariant instanceof Boolean) {
                            if ((Boolean) editableVariant)
                                flags.set(Editable);
                            metaData.propertyEditableResolvers.add(null);
                        } else if (editableVariant instanceof Method) {
                            flags.set(ResolveEditable);
                            metaData.propertyEditableResolvers.add((Method) editableVariant);
                        }else {
                            metaData.propertyEditableResolvers.add(null);
                        }
                        
                        if (storedVariant instanceof Boolean) {
                            if ((Boolean) storedVariant)
                                flags.set(PropertyFlags.Stored);
                            metaData.propertyStoredResolvers.add(null);
                        } else if (storedVariant instanceof Method) {
                                                        
                            flags.set(ResolveStored);
                            metaData.propertyStoredResolvers.add((Method) storedVariant);
                        }else {
                            metaData.propertyStoredResolvers.add(null);
                        }
                               
                        if (userVariant instanceof Boolean) {
                            if ((Boolean) userVariant)
                                flags.set(PropertyFlags.User);
                            metaData.propertyUserResolvers.add(null);
                        } else if (userVariant instanceof Method) {
                            flags.set(ResolveUser);
                            metaData.propertyUserResolvers.add((Method) userVariant);
                        }else {
                            metaData.propertyUserResolvers.add(null);
                        }
                        
                        if (Boolean.TRUE.equals(constantVariant) && writer!=null && notify!=null) {
                            flags.set(PropertyFlags.Constant);
                        }
                        
                        if (Boolean.TRUE.equals(requiredVariant) && Required!=null) {
                            flags.set(Required);
                        }

                        if (Boolean.TRUE.equals(finalVariant))
                            flags.set(PropertyFlags.Final);
                         
                        
                        if (notify!=null && Notify!=null)
                            flags.set(Notify);
                        
                     // properties: name, type, flags
                        metaData.metaData.add(metaData.addStringData(propertyName));
                        intdataComments.add("property["+i+"].name");
                        QMetaType.Type type = metaType(typeName);
                        if(type==QMetaType.Type.UnknownType || type==QMetaType.Type.User){
                        	if(metaTypeId==QMetaType.Type.UnknownType.value()) {
	                        	metaTypeId = QtJambiInternal.findMetaType(typeName);
	                            if(metaTypeId==QMetaType.Type.UnknownType.value() || !(genericPropertyType instanceof Class || new QMetaType(metaTypeId).name().toString().equals(typeName))) {
	                                metaTypeId = registerMetaType(propertyType, genericPropertyType, annotatedPropertyType, isPointer, isReference);
	                            }
	                            if(metaTypeId!=QMetaType.Type.UnknownType.value())
	                                typeName = new QMetaType(metaTypeId).name().toString();
                        	}
                            metaData.metaData.add(0x80000000 | metaData.addStringData(typeName));
                            metaData.metaTypes.set(i, metaTypeId);
                            metaData.propertyMetaTypes.add(new int[]{metaTypeId,metaTypeId});
                        }else{
                            metaData.metaData.add(type.value());
                            metaData.metaTypes.set(i, type.value());
                            metaData.propertyMetaTypes.add(new int[]{type.value(),type.value()});
                        }
                        metaData.propertyClassTypes.add(propertyType);
                        intdataComments.add("property["+i+"].type");
                        metaData.metaData.add(flags.value());
                        intdataComments.add("property["+i+"].flags");
                        Integer signalIndex = signalIndexes.get(notify);
                        if(QtJambiInternal.majorVersion()>5){
                            metaData.metaData.add(signalIndex!=null ? signalIndex : -1);
                            intdataComments.add("property["+i+"].notifyId");
                            metaData.metaData.add(0);
                            intdataComments.add("property["+i+"].revision");
                        }
                        
                        metaData.propertyReaders.add(reader);
                        metaData.propertyWriters.add(writer);
                        metaData.propertyResetters.add(resetter);
                        metaData.propertyNotifies.add(signalIndex);
                        metaData.propertyBindables.add(bindable);
                        metaData.propertyQPropertyFields.add(qPropertyField);
                        metaData.propertyMemberFields.add(propertyMemberField);
                        ++i;
                    }
                    
                    i=0;
                    for (String propertyName : propertyReaders.keySet()) {
                        Field notify = propertyNotifies.get(propertyName);
                        if(notify!=null) {
                        	int idx = 0x70000000;
                        	for(int j=0; j<metaData.signalInfos.size(); ++j) {
                        		if(metaData.signalInfos.get(j).field==notify) {
                        			idx = j;
                        			break;
                        		}
                        	}
                            metaData.metaData.add(idx);
                            intdataComments.add("property["+i+"].notify_signal_id");
                        }else {
                            metaData.metaData.add(0);
                            intdataComments.add("property["+i+"].notify_signal_id");
                        }
                        ++i;
                    }
                }
                
                if(metaObjectFlags!=0) {
                    metaData.metaData.set(flagsIndex, metaObjectFlags);
                }
                //
                // Build enums array
                //
                
                if(!enums.isEmpty()){
                    metaData.metaData.set(ENUM_METADATA_INDEX, metaData.metaData.size());
                    List<Class<?>> enumList = new ArrayList<Class<?>>(enums.values());
                    HashMap<Object,Integer> dataIndexOfEnums = new HashMap<Object,Integer>();
                    
                    for (int i = 0; i < enumList.size(); i++) {
                        Class<?> enumClass = enumList.get(i);
                        // enums: name, alias, flags, count, data
                        if(QtJambiInternal.majorVersion()>5){
                            String alias = enumClass.getSimpleName();
                            if(QFlags.class.isAssignableFrom(enumClass)) {
                                Class<?> _enumClass = getEnumForQFlags(enumClass);
                                alias = _enumClass.getSimpleName();
                            }
                            metaData.metaData.add(metaData.addStringData(enumClass.getSimpleName()));	intdataComments.add("enum["+i+"].name");
                            metaData.metaData.add(metaData.addStringData(alias));	intdataComments.add("enum["+i+"].alias");
                        }else{
                            metaData.metaData.add(metaData.addStringData(enumClass.getSimpleName()));	intdataComments.add("enum["+i+"].name");
                        }
                                                                                                                                               
                                                                                                                            
                        metaData.metaData.add(QFlags.class.isAssignableFrom(enumClass) ? 0x1 : 0x0);	intdataComments.add("enum["+i+"].flags");
                        
                        // Get the enum class
                        Class<?> contentEnumClass = Enum.class.isAssignableFrom(enumClass) ? enumClass : getEnumForQFlags(enumClass);
                        
                        if(contentEnumClass==null) {
                        	metaData.metaData.add(0);	intdataComments.add("enum["+i+"].count");
                        }else {
                        	Object[] enumConstants = contentEnumClass.getEnumConstants();
                        	metaData.metaData.add(enumConstants==null ? 0 : enumConstants.length);	intdataComments.add("enum["+i+"].count");
                        }
                        dataIndexOfEnums.put(enumClass, metaData.metaData.size());
                        metaData.metaData.add(0);	intdataComments.add("enum["+i+"].data");
                    }
                    
                    for (int i = 0; i < enumList.size(); i++) {
                        Class<?> enumClass = enumList.get(i);
                        @SuppressWarnings("unchecked")
                        Class<Enum<?>> contentEnumClass = (Class<Enum<?>>)(Enum.class.isAssignableFrom(enumClass) ? enumClass : getEnumForQFlags(enumClass));
                        // enum data: key, value
                        int ENUM_DATA_INDEX = dataIndexOfEnums.get(enumClass);
                        metaData.metaData.set(ENUM_DATA_INDEX, metaData.metaData.size());
                        if(contentEnumClass!=null) {
                        	Enum<?>[] enumConstants = contentEnumClass.getEnumConstants();
                        	if(enumConstants!=null) {
		                        for(Enum<?> enumConstant : enumConstants){
		                            metaData.metaData.add(metaData.addStringData(enumConstant.name()));	intdataComments.add("enum["+i+"].data: key");
		                            if(enumConstant instanceof QtEnumerator){
		                                QtEnumerator enumerator = (QtEnumerator)enumConstant;
		                                metaData.metaData.add(enumerator.value());
		                            }else if(enumConstant instanceof QtShortEnumerator){
		                                QtShortEnumerator enumerator = (QtShortEnumerator)enumConstant;
		                                metaData.metaData.add((int)enumerator.value());
		                            }else if(enumConstant instanceof QtByteEnumerator){
		                                QtByteEnumerator enumerator = (QtByteEnumerator)enumConstant;
		                                metaData.metaData.add((int)enumerator.value());
		                            }else if(enumConstant instanceof QtLongEnumerator){
		                                QtLongEnumerator enumerator = (QtLongEnumerator)enumConstant;
		                                metaData.metaData.add((int)enumerator.value());
		                            }else{
		                                metaData.metaData.add(enumConstant.ordinal());
		                            }
		                            intdataComments.add("enum["+i+"].data: value");
		                        }
                        	}
                        }
                    }
                }
                
                //
                // Terminate data array
                //
                metaData.metaData.add(0); // eod
                intdataComments.add("end of data");
            }

            if(intdataComments instanceof ArrayList) {
                List<String> nms = Arrays.asList(
                        "revision",
                        "className",
                        "classInfoCount",
                        "classInfoData",
                        "methodCount",
                        "methodData",
                        "propertyCount",
                        "propertyData",
                        "enumeratorCount",
                        "enumeratorData",
                        "constructorCount",
                        "constructorData",
                        "flags",
                        "signalCount"
                    );
                System.out.println(classname+": metaData.metaData{");
                for (int i = 0; i < metaData.metaData.size(); i++) {
                    try {
                        String strg = null;
                        try {
                            if(intdataComments.get(i).endsWith("]: name")) {
                                strg = metaData.stringData.get(metaData.metaData.get(i));
                            }else if(intdataComments.get(i).endsWith("].argName")) {
                                strg = metaData.stringData.get(metaData.metaData.get(i));
                            }else if(intdataComments.get(i).endsWith("].arg")) {
                                int idx = metaData.metaData.get(i);
                                if((idx & 0x80000000) == 0x80000000) {
                                    idx = idx & ~0x80000000;
                                    if(idx>=0 && idx<metaData.stringData.size())
                                        strg = metaData.stringData.get(idx);
                                }else if(idx>=0 && idx<QMetaType.Type.values().length){
                                    for(QMetaType.Type t : QMetaType.Type.values()) {
                                        if(t.value()==idx) {
                                            strg = ""+t;
                                            break;
                                        }
                                    }
                                }
                            }else if(intdataComments.get(i).endsWith("].returnType")) {
                                int idx = metaData.metaData.get(i);
                                if((idx & 0x80000000) == 0x80000000) {
                                    idx = idx & ~0x80000000;
                                    if(idx>=0 && idx<metaData.stringData.size())
                                        strg = metaData.stringData.get(idx);
                                }else if(idx>=0 && idx<QMetaType.Type.values().length){
                                    for(QMetaType.Type t : QMetaType.Type.values()) {
                                        if(t.value()==idx) {
                                            strg = ""+t;
                                            break;
                                        }
                                    }
                                }
                            }
                        } catch (Exception e) {
                            strg = "???";
                        }
                        if(strg!=null) {
                            if(i<nms.size()) {
                                System.out.printf("\t%1$s: %3$s=%2$s (%4$s) --> %5$s\n", i, metaData.metaData.get(i), intdataComments.get(i), nms.get(i), strg);
                            }else {
                                System.out.printf("\t%1$s: %3$s=%2$s --> %4$s\n", i, metaData.metaData.get(i), intdataComments.get(i), strg);
                            }
                        }else {
                            if(i<nms.size()) {
                                System.out.printf("\t%1$s: %3$s=%2$s (%4$s)\n", i, metaData.metaData.get(i), intdataComments.get(i), nms.get(i));
                            }else {
                                System.out.printf("\t%1$s: %3$s=%2$s\n", i, metaData.metaData.get(i), intdataComments.get(i));
                            }
                        }
                    } catch (IndexOutOfBoundsException e) {
                        System.out.printf("\t%1$s: %2$s\n", i, metaData.metaData.get(i));
                    }
                }
                System.out.println("}");
            }
            
//			for (int i = 0; i < metaData.stringData.size(); i++) {
//				System.out.printf("string[%1$s]= %2$s\n", i, metaData.stringData.get(i));
//			}
            return metaData;
        } catch (RuntimeException | Error e) {
            throw e;
        } catch (Throwable e) {
            throw new RuntimeException(e);
        }
    }

    private static boolean overridesGeneratedSlot(Method declaredMethod, Class<?> clazz) {
        if(!Modifier.isPrivate(declaredMethod.getModifiers()) && !Modifier.isStatic(declaredMethod.getModifiers()) && clazz.getSuperclass()!=null) {
            try {
                Method declaredSuperMethod = clazz.getSuperclass().getDeclaredMethod(declaredMethod.getName(), declaredMethod.getParameterTypes());
                if(declaredSuperMethod!=null) {
                    Class<?> declaringClass = declaredSuperMethod.getDeclaringClass();
                    if(QtJambiInternal.isGeneratedClass(declaringClass)) {
                        return true;
                    }else {
                        return overridesGeneratedSlot(declaredSuperMethod, declaringClass);
                    }
                }
            } catch (Throwable e) {
            }
        }
        return false;
    }

    // Using a variable to ensure this is changed in all the right places in the
    //  future when higher values are supported.
    public static final int METAOBJECT_REVISION_HIGHEST_SUPPORTED = QtJambiInternal.majorVersion()==5 ? 7 : 9;
    // This property allows you to override the QMetaObject revision number for
    //  QtJambi to use.
    public static final String K_io_qt_qtjambi_metadata_revision = "io.qt.qtjambi.metadata.revision";
    private static int revision;
    // This should be updated as the code-base supports the correct data layout
    //  for each new revision.  We don't necessarily have to support the features
    //  that new revision brings as well.
    private static int resolveMetaDataRevision() {
        int r = revision;
        if(r != 0)
            return r;

        int major = QtJambiInternal.majorVersion();
        int minor = QtJambiInternal.minorVersion();
        // It became a requirement in 4.7.x to move away from revision 1
        //  in order to restore broken functionality due to improvements
        //  in Qt.  Before this time QtJambi always used to report
        //  revision=1.
        // The following is the default version for that version of Qt
        //  this is compatible with what QtJambi provides and needs to
        //  be updated with any future revision.
        if(major <= 3)
            r = 1;  // Good luck with getting QtJambi working!
        else if(major == 4 && minor <= 5)
            r = 1;  // historically this version was used
        else if(major == 4 && minor == 6)
            r = 4;  // 4.6.x (historically revision 1 was used)
        else if(major == 4 && minor == 7)
            r = 5;  // 4.7.x (known issues with 1 through 3, use revision 4 minimum, 5 is best)
        else if(major == 4)
            r = 6;  // 4.8.x
        else if(major == 5)
            r = 7;  // 5.0.x (Qt5 requires a minimum of this revision)
        else if(major == 6)
            r = 9;  // 6.0.x (Qt6 requires a minimum of this revision)
        else  // All future versions
            r = METAOBJECT_REVISION_HIGHEST_SUPPORTED;

        // The above computes the automatic default so we can report it below
        int revisionOverride = resolveMetaDataRevisionFromSystemProperty(r);
        if(revisionOverride > 0)
            r = revisionOverride;

        revision = r;
        return r;
    }

    /**
     * A facility to override the default metadata revision with a system property.
     * More useful for testing and fault diagnosis than any practical runtime purpose.
     * @param defaultRevision Value only used in error messages.
     * @return -1 on parse error, 0 when no configured, >0 is a configured value.
     */
    private static int resolveMetaDataRevisionFromSystemProperty(int defaultRevision) {
        int r = 0;
        String s = null;
        try {
            s = System.getProperty(K_io_qt_qtjambi_metadata_revision);
            if(s != null) {
                r = Integer.parseInt(s);
                if(r <= 0 || r > METAOBJECT_REVISION_HIGHEST_SUPPORTED)
                    r = -1;  // invalidate causing the value to be ignored
            }
        } catch(NumberFormatException e) {
            r = -1;
        } catch(SecurityException e) {
            java.util.logging.Logger.getLogger("io.qt.internal").log(java.util.logging.Level.SEVERE, "", e);
        }
        if(r < 0)
            System.err.println("System Property " + K_io_qt_qtjambi_metadata_revision + " invalid value: " + s + " using default: " + defaultRevision);
        return r;
    }
    
    private static boolean isBuiltinType(String type)
    {
        QMetaType.Type id = metaType(type);
       if (id == QMetaType.Type.UnknownType)
           return false;
       return (id.value() < QMetaType.Type.User.value());
    }
    
    static QMetaType.Type metaType(String typeName){
        if("double".equals(typeName)){
            return QMetaType.Type.Double;
        }
        if("int".equals(typeName)){
            return QMetaType.Type.Int;
        }
        if("float".equals(typeName)){
            return QMetaType.Type.Float;
        }
        if("boolean".equals(typeName) || "bool".equals(typeName)){
            return QMetaType.Type.Bool;
        }
        if("short".equals(typeName)){
            return QMetaType.Type.Short;
        }
        if("long".equals(typeName)){
            return QMetaType.Type.Long;
        }
        if("byte".equals(typeName) || "char".equals(typeName)){
            return QMetaType.Type.Char;
        }
        if("void".equals(typeName)){
            return QMetaType.Type.Void;
        }
        try {
            return QMetaType.Type.valueOf(typeName);
        } catch (Exception e) {
            for(QMetaType.Type t : QMetaType.Type.values()){
                if(typeName.endsWith(t.name())){
                    return t;
                }
            }
            return QMetaType.Type.User;
        }
    }
	
	private static long findEmitMethodId(Class<?> signalClass, List<Class<?>> signalTypes) {
		Map<List<Class<?>>,QtJambiSignals.EmitMethodInfo> emitMethods = QtJambiSignals.findEmitMethods(signalClass);
		QtJambiSignals.EmitMethodInfo result;
		if(emitMethods.isEmpty())
			result = null;
		else if(emitMethods.size()==1) {
			if(signalTypes==null) {
				result = emitMethods.entrySet().iterator().next().getValue();
			}else {
				result = emitMethods.get(signalTypes);
			}
		}else {
			if(signalTypes==null) {
				result = emitMethods.get(emitMethods.keySet().stream().max((t1, t2)->t1.size() > t2.size() ? 1 : -1).orElse(null));
			}else {
				result = emitMethods.get(signalTypes);
			}
		}
		return result==null ? 0 : result.methodId;
	}

	/**
	 * Returns true if the class cl represents a Signal.
	 * 
	 * @return True if the class is a signal
	 * @param cl The class to check
	 */
	public static boolean isQObjectSignalType(Class<?> cl) {
		return QtJambiSignals.AbstractSignal.class.isAssignableFrom(cl)
				&& !Modifier.isAbstract(cl.getModifiers())
				&& cl.getEnclosingClass() != QMetaObject.class
				&& cl.getEnclosingClass() != QStaticMemberSignals.class
				&& cl.getEnclosingClass() != QDeclarableSignals.class && !QtJambiSignals.findEmitMethods(cl).isEmpty();
	}
}
