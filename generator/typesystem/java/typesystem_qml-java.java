/****************************************************************************
**
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
** In addition, as a special exception, Nokia gives you certain
** additional rights. These rights are described in the Nokia Qt LGPL
** Exception version 1.0, included in the file LGPL_EXCEPTION.txt in this
** package.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3.0 as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU General Public License version 3.0 requirements will be
** met: http://www.gnu.org/copyleft/gpl.html.
**
** $END_LICENSE$

**
** This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
** WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
**
****************************************************************************/

class __QQmlComponent extends QQmlComponent{

    @io.qt.QtUninvokable
    public final void setData(String data, io.qt.core.QUrl baseUrl)    {
        setData(new io.qt.core.QByteArray(data), baseUrl);
    }

    @io.qt.QtUninvokable
    public final void setData(byte[] data, io.qt.core.QUrl baseUrl)    {
        setData(new io.qt.core.QByteArray(data), baseUrl);
    }
    
    @io.qt.QtUninvokable
    public <T extends io.qt.core.QObject> T create(Class<T> type)    {
        return create(type, (io.qt.qml.QQmlContext)null);
    }

    @io.qt.QtUninvokable
    public <T extends io.qt.core.QObject> T create(Class<T> type, io.qt.qml.QQmlContext context)    {
        String packageName = type.getName();
        int idx = packageName.lastIndexOf('.');
        if(idx>0){
            packageName = packageName.substring(0, idx);
        }
        io.qt.QtUtilities.initializePackage(packageName);
        return type.cast(create(context));
    }
}// class

class __QJSValue extends QJSValue{

    @io.qt.QtUninvokable
    public final void setProperty(java.lang.String name, String value)    {
        setProperty(name, new QJSValue(value));
    }
    
    @io.qt.QtUninvokable
    public final void setProperty(java.lang.String name, boolean value)    {
        setProperty(name, new QJSValue(value));
    }
    
    @io.qt.QtUninvokable
    public final void setProperty(java.lang.String name, double value)    {
        setProperty(name, new QJSValue(value));
    }
    
    @io.qt.QtUninvokable
    public final void setProperty(java.lang.String name, int value)    {
        setProperty(name, new QJSValue(value));
    }
    
    @io.qt.QtUninvokable
    public final void setProperty(java.lang.String name, QJSValue.SpecialValue value)    {
        setProperty(name, new QJSValue(value));
    }
    
    @io.qt.QtUninvokable
    public final void setProperty(int arrayIndex, String value)    {
        setProperty(arrayIndex, new QJSValue(value));
    }
    
    @io.qt.QtUninvokable
    public final void setProperty(int arrayIndex, boolean value)    {
        setProperty(arrayIndex, new QJSValue(value));
    }
    
    @io.qt.QtUninvokable
    public final void setProperty(int arrayIndex, double value)    {
        setProperty(arrayIndex, new QJSValue(value));
    }
    
    @io.qt.QtUninvokable
    public final void setProperty(int arrayIndex, int value)    {
        setProperty(arrayIndex, new QJSValue(value));
    }
    
    @io.qt.QtUninvokable
    public final void setProperty(int arrayIndex, QJSValue.SpecialValue value)    {
        setProperty(arrayIndex, new QJSValue(value));
    }

}// class

class __QtQml__ extends QtQml{

	/**
     * Returns the QJSEngine associated with object, if any.
	 *
     * This function is useful if you have exposed a QObject to the JavaScript environment
     * and later in your program would like to regain access. It does not require you to
     * keep the wrapper around that was returned from QJSEngine::newQObject().
     */
	@io.qt.QtUninvokable
    public static QJSEngine qjsEngine(io.qt.core.QObject object){
		return qjsEngine(QtJambi_LibraryUtilities.internal.nativeId(object));
	}
	
	private static native QJSEngine qjsEngine(long object);

    public static native int qmlRegisterTypeNotAvailable(String uri, int versionMajor, int versionMinor, String qmlName, String message);
    
    public static native int qmlRegisterUncreatableType(Class<? extends QObject> type, String uri, int versionMajor, int versionMinor, String qmlName, String reason);
    
    public static native int qmlRegisterUncreatableType(Class<? extends QObject> type, int metaObjectRevision, String uri, int versionMajor, int versionMinor, String qmlName, String reason);
    
    public static native int qmlRegisterType(Class<? extends QObject> type, String uri, int versionMajor, int versionMinor, String qmlName);
    
    public static native int qmlRegisterType(Class<? extends QObject> type, int metaObjectRevision, String uri, int versionMajor, int versionMinor, String qmlName);
    
    public static native int qmlRegisterRevision(Class<? extends QObject> type, int metaObjectRevision, String uri, int versionMajor, int versionMinor);

    public static native int qmlRegisterExtendedType(Class<? extends QObject> type, Class<? extends QObject> extendedType, String uri, int versionMajor, int versionMinor, String qmlName);

    public static QObject qmlAttachedPropertiesObject(Class<? extends QObject> clazz, QObject obj){
        return qmlAttachedPropertiesObject(clazz, obj, true);
    }

    public static native QObject qmlAttachedPropertiesObject(Class<? extends QObject> clazz, QObject obj, boolean create);

    public static native int qmlRegisterAnonymousType(Class<? extends QObject> type, String uri, int versionMajor);

    public static native int qmlRegisterType(QUrl url, String uri, int versionMajor, int versionMinor, String qmlName);
	
    public static native int qmlTypeId(String uri, int versionMajor, int versionMinor, String qmlName);
    
    public static native boolean qmlProtectModule(String uri, int majVersion);

    public static native void qmlClearTypeRegistrations();

    public static native int qmlRegisterExtendedUncreatableType(Class<? extends QObject> type, Class<? extends QObject> extendedType, String uri, int versionMajor, int versionMinor, String qmlName, String reason);

    public static native int qmlRegisterExtendedUncreatableType(Class<? extends QObject> type, Class<? extends QObject> extendedType, int metaObjectRevision, String uri, int versionMajor, int versionMinor, String qmlName, String reason);

    public static native void qmlRegisterModule(String uri, int versionMajor, int versionMinor);
    
    public static native int qmlRegisterSingletonType(String uri, int versionMajor, int versionMinor, String typeName, ValueCallback callback);

    public static native int qmlRegisterSingletonType(Class<? extends QObject> type, String uri, int versionMajor, int versionMinor, String typeName, ObjectCallback callback);
    
    public static native int qmlRegisterSingletonType(QUrl url, String uri, int versionMajor, int versionMinor, String qmlName);
    
    public static int qmlRegisterSingletonInstance(QObject instance, String uri, int versionMajor, int versionMinor, String qmlName){
        return qmlRegisterSingletonType(instance.getClass(), uri, versionMajor, versionMinor, qmlName, (e,v)->instance);
    }

    public static native int qmlRegisterUncreatableClass(Class<?> type, String uri, int versionMajor, int versionMinor, String qmlName, String reason);

}// class

class __QtQml_5_13 extends QtQml{

    public static native void qmlRegisterBaseTypes(String uri, int versionMajor, int versionMinor);
    
}// class

class __QtQml_5_14 extends QtQml{

    public static native int qmlRegisterType(Class<? extends QObject> type);
    
    public static int qmlRegisterInterface(Class<? extends io.qt.QtObjectInterface> type, String typeName){
        return type.isInterface() ? qmlRegisterInterface1(type, typeName) : -1;
    }
    
    private static native int qmlRegisterInterface1(Class<? extends io.qt.QtObjectInterface> type, String typeName);

    public static native int qmlRegisterExtendedType(Class<? extends QObject> type, Class<? extends QObject> extendedType);

}// class

class __QtQml_5_15 extends QtQml{
    /**
     * @deprecated Use qmlRegisterAnonymousType instead
     */
    @Deprecated
    public static native int qmlRegisterType(Class<? extends QObject> type);
    
    /**
     * @deprecated Use qmlRegisterInterface(Class<? extends io.qt.QtObjectInterface> type, String uri, int versionMajor)
     */
    @Deprecated
    public static int qmlRegisterInterface(Class<? extends io.qt.QtObjectInterface> type, String typeName){
        return type.isInterface() ? qmlRegisterInterface1(type, typeName) : -1;
    }
    
    private static native int qmlRegisterInterface1(Class<? extends io.qt.QtObjectInterface> type, String typeName);

    public static int qmlRegisterInterface(Class<? extends io.qt.QtObjectInterface> type, String uri, int versionMajor){
        return type.isInterface() ? qmlRegisterInterface2(type, uri, versionMajor) : -1;
    }
    
    private static native int qmlRegisterInterface2(Class<? extends io.qt.QtObjectInterface> type, String uri, int versionMajor);

    /**
     * @deprecated Use qmlRegisterExtendedType(type, uri, versionMajor) instead
     */
    @Deprecated
    public static native int qmlRegisterExtendedType(Class<? extends QObject> type, Class<? extends QObject> extendedType);
    
    public static native int qmlRegisterExtendedType(Class<? extends QObject> type, Class<? extends QObject> extendedType, String uri, int versionMajor);

}// class

class QQmlProperty__{
    
    @io.qt.QtUninvokable
    public final boolean connectNotifySignal(io.qt.core.QMetaObject.Slot0 slot){
    	return connectNotifySignal(slot, io.qt.core.QMetaMethod.fromMethod(java.util.Objects.requireNonNull(slot)));
    }
    
    @io.qt.QtUninvokable
    public final boolean connectNotifySignal(io.qt.core.QMetaObject.Slot1<?> slot){
    	return connectNotifySignal(slot, io.qt.core.QMetaMethod.fromMethod(java.util.Objects.requireNonNull(slot)));
    }
    
    @io.qt.QtUninvokable
    private final boolean connectNotifySignal(io.qt.core.QMetaObject.AbstractSlot slot, io.qt.core.QMetaMethod metaMethod){
        if(metaMethod!=null && metaMethod.isValid()) {
			io.qt.core.QObject qobject = QtJambi_LibraryUtilities.internal.lambdaContext(slot);
			if(qobject!=null)
				return connectNotifySignal(qobject, metaMethod.methodIndex());
        }
        return false;
    }
    
}// class

class QJSEngine__{

	@io.qt.QtUninvokable
    public final QJSValue newQMetaObject(Class<?> type) {
    	return newQMetaObject(io.qt.core.QMetaObject.forType(type));
    }
}// class

class QJSEngine_6_{
	@io.qt.QtUninvokable
    public final <T> T fromScriptValue(QJSValue value, Class<T> type, io.qt.core.QMetaType...instantiations) {
    	return fromScriptValue(value, io.qt.core.QMetaType.fromType(type, instantiations));
    }
    
    @io.qt.QtUninvokable
    public final <T> T fromScriptValue(QJSValue value, io.qt.core.QMetaType type) {
    	return fromScriptValue(QtJambi_LibraryUtilities.internal.nativeId(this), QtJambi_LibraryUtilities.internal.checkedNativeId(value), QtJambi_LibraryUtilities.internal.checkedNativeId(type));
    }
    
    private static native <T> T fromScriptValue(long thisId, long valueId, long typeId);
    
    @io.qt.QtUninvokable
    public final <T> QJSValue toScriptValue(T value) {
    	return toScriptValue(QtJambi_LibraryUtilities.internal.nativeId(this), value);
    }
    
    private static native QJSValue toScriptValue(long thisId, Object value);
}// class

class QJSEngine_61_{
    @io.qt.QtUninvokable
    public final <T> T fromManagedValue(QJSManagedValue value, Class<T> type, io.qt.core.QMetaType...instantiations) {
    	return fromManagedValue(value, io.qt.core.QMetaType.fromType(type, instantiations));
    }
    
    @io.qt.QtUninvokable
    public final <T> T fromManagedValue(QJSManagedValue value, io.qt.core.QMetaType type) {
    	return fromManagedValue(QtJambi_LibraryUtilities.internal.nativeId(this), QtJambi_LibraryUtilities.internal.checkedNativeId(value), QtJambi_LibraryUtilities.internal.checkedNativeId(type));
    }
    
    private static native <T> T fromManagedValue(long thisId, long valueId, long typeId);
    
    @io.qt.QtUninvokable
    public final <T> QJSManagedValue toManagedValue(T value) {
    	return toManagedValue(QtJambi_LibraryUtilities.internal.nativeId(this), value);
    }
    
    private static native QJSManagedValue toManagedValue(long thisId, Object value);
    
}// class

class QJSEngine_63_{
    @io.qt.QtUninvokable
    public final <T> T fromVariant(Object variant, Class<T> type, io.qt.core.QMetaType...instantiations) {
    	return fromVariant(variant, io.qt.core.QMetaType.fromType(type, instantiations));
    }
    
    @io.qt.QtUninvokable
    public final <T> T fromVariant(Object variant, io.qt.core.QMetaType type) {
    	return fromVariant(QtJambi_LibraryUtilities.internal.nativeId(this), variant, QtJambi_LibraryUtilities.internal.checkedNativeId(type));
    }
    
    private static native <T> T fromVariant(long thisId, Object variant, long typeId);
	
}// class

class QQmlEngine__{
	
	/**
     * <p>See <a href="https://doc.qt.io/qt/qqmlengine.html#singletonInstance">QQmlEngine::singletonInstance(int qmlTypeId)</a></p>
     */
    @io.qt.QtUninvokable
    public final <T extends io.qt.QtObjectInterface> T singletonInstance(Class<T> type, int qmlTypeId) {
    	io.qt.core.QObject object = singletonInstance(QtJambi_LibraryUtilities.internal.nativeId(this), qmlTypeId).toQObject();
    	if(object!=null)
    		return object.qt_metacast(type);
    	return null;
    }
    
    /**
     * <p>See <a href="https://doc.qt.io/qt/qqmlengine.html#singletonInstance">QQmlEngine::singletonInstance(int qmlTypeId)</a></p>
     */
    @io.qt.QtUninvokable
    public final QJSValue singletonInstance(int qmlTypeId) {
    	return singletonInstance(QtJambi_LibraryUtilities.internal.nativeId(this), qmlTypeId);
    }
    
    @io.qt.QtUninvokable
    private static native QJSValue singletonInstance(long __this__nativeId, int qmlTypeId);
	
}// class

class QQmlExpression__{
    public static class ValueIsUndefined extends RuntimeException{
        private static final long serialVersionUID = 7719401165632826435L;
        private ValueIsUndefined(String message) {
            super(message);
        }
    }

}// class

class QQmlPropertyValueSource__header__{

public:
    QQmlPropertyValueSource_shell(JNIEnv *__jni_env, jobject __jni_object, const QWeakPointer<QtJambiLink>& link);
}// class

class QQmlPropertyValueSource__native__{

QQmlPropertyValueSource_shell::QQmlPropertyValueSource_shell(JNIEnv *__jni_env, jobject __jni_object, const QWeakPointer<QtJambiLink>& link)
    : QQmlPropertyValueSource(),
      m_vtable(qtjambi_setup_vtable(__jni_env, __jni_object, "QQmlPropertyValueSource")),
      m_link(link)
{
    QTJAMBI_DEBUG_METHOD_PRINT("shell", "QQmlPropertyValueSource::QQmlPropertyValueSource(JNIEnv *__jni_env, jobject __jni_object, link)");
#ifdef QT_DEBUG
    if (m_vtable)
        m_vtable->ref();
#endif
}
}// class

class QQmlParserStatus__header__{

public:
    QQmlParserStatus_shell(JNIEnv *__jni_env, jobject __jni_object, const QWeakPointer<QtJambiLink>& link);
}// class

class QQmlParserStatus__native__{

QQmlParserStatus_shell::QQmlParserStatus_shell(JNIEnv *__jni_env, jobject __jni_object, const QWeakPointer<QtJambiLink>& link)
    : QQmlParserStatus(),
      m_vtable(qtjambi_setup_vtable(__jni_env, __jni_object, "QQmlParserStatus")),
      m_link(link)
{
    QTJAMBI_DEBUG_METHOD_PRINT("shell", "QQmlParserStatus_shell::QQmlParserStatus_shell(JNIEnv *__jni_env, jobject __jni_object, link)");
#ifdef QT_DEBUG
    if (m_vtable)
        m_vtable->ref();
#endif
}
}// class

class QQmlIncubationController__{
public static class WhileFlag{
    private final long flag;
        public WhileFlag() {
            this(true);
        }
        
        public WhileFlag(boolean flag) {
            long ptr = create(flag);
            this.flag = ptr;
            QtJambi_LibraryUtilities.internal.registerCleaner(this, ()->destroy(ptr));
        }
        
        public void set(boolean flag) {
        	set(this.flag, flag);
        }
        
        private static native long create(boolean flag);
        
        private static native void destroy(long ptr);
        
        private static native void set(long ptr, boolean flag);
    }
}// class

class QQmlIncubationController_native__{
}// class

class QJSPrimitiveValue__{
    @io.qt.QtUninvokable
    @Deprecated
    public final io.qt.qml.QJSPrimitiveValue modulo(io.qt.qml.QJSPrimitiveValue rhs){
        return mod(rhs);
    }
    
    @io.qt.QtUninvokable
    @Deprecated
    public final io.qt.qml.QJSPrimitiveValue multiplied(io.qt.qml.QJSPrimitiveValue rhs){
        return times(rhs);
    }
    
    @io.qt.QtUninvokable
    @Deprecated
    public final io.qt.qml.QJSPrimitiveValue added(io.qt.qml.QJSPrimitiveValue rhs){
        return plus(rhs);
    }
    
    @io.qt.QtUninvokable
    @Deprecated
    public final io.qt.qml.QJSPrimitiveValue divided(io.qt.qml.QJSPrimitiveValue rhs){
        return div(rhs);
    }
    
    @io.qt.QtUninvokable
    @Deprecated
    public final io.qt.qml.QJSPrimitiveValue substracted(io.qt.qml.QJSPrimitiveValue rhs){
        return minus(rhs);
    }
}// class
