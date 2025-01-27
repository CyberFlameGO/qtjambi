/****************************************************************************
**
** Copyright (C) 2009-2023 Dr. Peter Droste, Omix Visualization GmbH & Co. KG. All rights reserved.
**
** This file is part of QtJambi.
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

import QtJambiGenerator 1.0

TypeSystem{
    packageName: "io.qt.core"
    defaultSuperClass: "io.qt.QtObject"
    qtLibrary: "QtCore"
    module: "qtjambi"
    description: "<p>QtJambi base module containing QtCore, QtGui and QtWidgets.</p>\n"+
                 "<ul>\n"+
                 "<li>QtCore - Core non-graphical classes used by other modules.</li>\n"+
                 "<li>QtGui - Base classes for graphical user interface (GUI) components. Includes OpenGL.</li>\n"+
                 "<li>QtWidgets - Classes to extend Qt GUI with C++ widgets.</li>\n"+
                 "</ul>"
    InjectCode{
        target: CodeClass.MetaInfo
        position: Position.Position1
        Text{content: "void initialize_meta_info_QtCore();"}
    }
    
    InjectCode{
        target: CodeClass.MetaInfo
        position: Position.End
        Text{content: "initialize_meta_info_QtCore();"}
    }
    
    InjectCode{
        target: CodeClass.Java
        position: Position.End
        Text{content: "QLogging.initialize();\n"+
                      "QThread.initialize();"}
    }
    
    InjectCode{
        packageName: "io.qt.internal"
        target: CodeClass.Java
        position: Position.Beginning
        Text{content: "final static java.util.Properties properties = new java.util.Properties();\n"+
                      "\n"+
                      "@io.qt.QtUninvokable private static native void shutdown();"}
    }
    
    InjectCode{
        packageName: "io.qt.internal"
        target: CodeClass.Java
        position: Position.Position1
        Text{content: "Thread shutdownHook = null;"}
    }
    
    InjectCode{
        packageName: "io.qt.internal"
        target: CodeClass.Java
        position: Position.Position2
        ImportFile{
            name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
            quoteAfterLine: "class QtJambi_LibraryUtilities_2_"
            quoteBeforeLine: "}// class"
        }
    }
    
    InjectCode{
        packageName: "io.qt.internal"
        target: CodeClass.Java
        position: Position.Position4
        Text{content: "if(shutdownHook!=null)\n"+
                      "    Runtime.getRuntime().removeShutdownHook(shutdownHook);\n"+
                      "LibraryUtility.clear();"}
    }
    
    InjectCode{
        target: CodeClass.ModuleInfo
        position: Position.End
        Text{content: "requires transitive java.logging;\n"+
                      "requires java.xml;\n"+
                      "requires java.prefs;\n"+
                      "opens io.qt.internal to qtjambi.autotests;\n"+
                      "exports io.qt.internal to qtjambi.deployer, qtjambi.generator, qtjambi.autotests;\n"+
                      "exports io.qt;"}
    }
    
    Template{
        name: "core.comsumer.function"
        Text{content: "std::function<void(%TYPE)> %out;\n"+
                      "if(%in){\n"+
                      "    JObjectWrapper wrapper(%env, %in);\n"+
                      "    %out = [wrapper](%TYPE value){\n"+
                      "                                if(JniEnvironment env{200}){\n"+
                      "                                    jobject _value = qtjambi_cast<jobject>(env, value);\n"+
                      "                                    Java::Runtime::Consumer::accept(env, wrapper.object(), _value);\n"+
                      "                                }\n"+
                      "                            };\n"+
                      "}"}
    }
    
    Template{
        name: "core.runnable.function"
        Text{content: "std::function<void()> %out;\n"+
                      "if(%in){\n"+
                      "    JObjectWrapper wrapper(%env, %in);\n"+
                      "    %out = [wrapper](){\n"+
                      "        if(JniEnvironment env{200}){\n"+
                      "            Java::Runtime::Runnable::run(env, wrapper.object());\n"+
                      "        }\n"+
                      "    };\n"+
                      "}"}
    }
    
    Template{
        name: "core.supplier.function"
        Text{content: "std::function<%TYPE()> %out;\n"+
                      "if(%in){\n"+
                      "    JObjectWrapper wrapper(%env, %in);\n"+
                      "    %out = [wrapper]() -> %TYPE {\n"+
                      "            if(JniEnvironment env{200}){\n"+
                      "                jobject value = Java::Runtime::Supplier::get(env, wrapper.object());\n"+
                      "                return qtjambi_cast<%TYPE>(env, value);\n"+
                      "            }\n"+
                      "            return {};\n"+
                      "        };\n"+
                      "}"}
    }
    
    Template{
        name: "core.AtomicReference_to_ptr"
        Text{content: "%TYPE* %out = nullptr;\n"+
                      "if(%in){\n"+
                      "    jobject obj = %env->CallObjectMethod(%in, _AtomicReference->get);\n"+
                      "    JavaException::check(%env QTJAMBI_STACKTRACEINFO );\n"+
                      "    %out = new %TYPE( qtjambi_cast<%TYPE>(%env, obj) );\n"+
                      "    %scope.addFinalAction([%env,_AtomicReference,%in,%out](){\n"+
                      "            QScopedPointer<%TYPE> ptr(%out);\n"+
                      "            Java::Runtime::AtomicReference::set(%env, %in, qtjambi_cast<jobject>(%env, *%out));\n"+
                      "        });\n"+
                      "}"}
    }
    
    Template{
        name: "core.ptr_to_AtomicReference"
        Text{content: "jobject %out = nullptr;\n"+
                      "if(%in){\n"+
                      "    %out = Java::Runtime::AtomicReference::newInstance(%env, qtjambi_cast<jobject>(%env, *%in));\n"+
                      "    %scope.addFinalAction([%env,_AtomicReference,%in,%out](){\n"+
                      "            *%in = qtjambi_cast<%TYPE>(%env, Java::Runtime::AtomicReference::get(%env, %out));\n"+
                      "        });\n"+
                      "}"}
    }
    
    Template{
        name: "core.std_iterator_to_java_util_Iterator"
        Text{content: "@Override\n"+
                      "@io.qt.QtUninvokable\n"+
                      "public final java.util.Iterator<%ELEMENT_TYPE> iterator() {\n"+
                      "    return constBegin().toJavaIterator();\n"+
                      "}"}
    }
    
    Template{
        name: "core.self_iterator"
        Text{content: "@Override\n"+
                      "@io.qt.QtUninvokable\n"+
                      "public final java.util.Iterator<%ELEMENT_TYPE> iterator() {\n"+
                      "    return this;\n"+
                      "}"}
    }
    
    Template{
        name: "core.to_iterator"
        Text{content: "@Override\n"+
                      "@io.qt.QtUninvokable\n"+
                      "public final %ITERATOR_TYPE iterator() {\n"+
                      "    return new %ITERATOR_TYPE(this);\n"+
                      "}"}
    }
    
    Template{
        name: "core.return_string_instead_of_char*"
        Text{content: "public final String %FUNCTION_NAME() {\n"+
                      "    QNativePointer np = %FUNCTION_NAME_private();\n"+
                      "    String returned = \"\";\n"+
                      "    int i=0;\n"+
                      "    while (np.byteAt(i) != 0) returned += (char) np.byteAt(i++);\n"+
                      "    return returned;\n"+
                      "}"}
    }
    
    Template{
        name: "core.call_with_string_instead_of_char*"
        Text{content: "public final void %FUNCTION_NAME(String %ARG_NAME) {\n"+
                      "    %FUNCTION_NAME(QNativePointer.createCharPointer(%ARG_NAME));\n"+
                      "}"}
    }
    
    Template{
        name: "core.private_function_return_self"
        Text{content: "public final %RETURN_TYPE %FUNCTION_NAME(%ARGUMENTS) {\n"+
                      "    %FUNCTION_NAME_private(%ARGUMENT_NAMES);\n"+
                      "    return this;\n"+
                      "}"}
    }
    
    Template{
        name: "core.unary_other_type"
        InsertTemplate{
            name: "core.private_function_return_self"
            Replace{
                from: "%RETURN_TYPE"
                to: "%OUT_TYPE"
            }
            Replace{
                from: "%ARGUMENTS"
                to: "%IN_TYPE other"
            }
            Replace{
                from: "%ARGUMENT_NAMES"
                to: "other"
            }
        }
    }
    
    Template{
        name: "core.unary_self_type"
        InsertTemplate{
            name: "core.unary_other_type"
            Replace{
                from: "%IN_TYPE"
                to: "%TYPE"
            }
            Replace{
                from: "%OUT_TYPE"
                to: "%TYPE"
            }
        }
    }
    
    Template{
        name: "core.operator_assign_self_type"
        InsertTemplate{
            name: "core.unary_self_type"
            Replace{
                from: "%FUNCTION_NAME"
                to: "operator_assign"
            }
        }
    }
    
    Template{
        name: "core.operator_assign_other_type"
        InsertTemplate{
            name: "core.unary_other_type"
            Replace{
                from: "%FUNCTION_NAME"
                to: "operator_assign"
            }
        }
    }
    
    Template{
        name: "core.call_through_with_byte[]_instead_of_char*_and_int"
        Text{content: "public final int %FUNCTION_NAME(byte data[]) {\n"+
                      "    QNativePointer np = new QNativePointer(QNativePointer.Type.Byte, data.length);\n"+
                      "    %COPY_IN\n"+
                      "    int returned = (int) %FUNCTION_NAME(np, data.length);\n"+
                      "    %COPY_OUT\n"+
                      "    return returned;\n"+
                      "}"}
    }
    
    Template{
        name: "core.read_with_byte[]_instead_of_char*_and_int"
        InsertTemplate{
            name: "core.call_through_with_byte[]_instead_of_char*_and_int"
            Replace{
                from: "%COPY_IN"
                to: ""
            }
            Replace{
                from: "%COPY_OUT"
                to: "for (int i=0; i<returned; ++i) data[i] = np.byteAt(i);"
            }
        }
    }
    
    Template{
        name: "core.write_with_byte[]_instead_of_char*_and_int"
        InsertTemplate{
            name: "core.call_through_with_byte[]_instead_of_char*_and_int"
            Replace{
                from: "%COPY_OUT"
                to: ""
            }
            Replace{
                from: "%COPY_IN"
                to: "for (int i=0; i<data.length; ++i) np.setByteAt(i, data[i]);"
            }
        }
    }
    
    Template{
        name: "core.stream_operator_shift_right"
        Text{content: "public final %STREAM_TYPE operator_shift_right(%TYPE array[]) {\n"+
                      "    QNativePointer np = new QNativePointer(QNativePointer.Type.%NATIVEPOINTER_TYPE);\n"+
                      "    for (int i=0; i<array.length; ++i) {\n"+
                      "        operator_shift_right_%TYPE(np);\n"+
                      "        array[i] = np.%VALUE_FUNCTION();\n"+
                      "    }\n"+
                      "    \n"+
                      "    return this;\n"+
                      "}"}
    }
    
    PrimitiveType{
        name: "bool"
        javaName: "boolean"
        jniName: "jboolean"
    }
    
    PrimitiveType{
        name: "double"
        jniName: "jdouble"
    }
    
    PrimitiveType{
        name: "float"
        jniName: "jfloat"
    }
    
    PrimitiveType{
        name: "qfloat16"
        javaName: "float"
        jniName: "jfloat"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "qreal"
        javaName: "double"
        jniName: "jdouble"
    }
    
    PrimitiveType{
        name: "__int64"
        javaName: "long"
        jniName: "jlong"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "unsigned __int64"
        javaName: "long"
        jniName: "jlong"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "size_t"
        javaName: "long"
        jniName: "jlong"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "unsigned long long"
        javaName: "long"
        jniName: "jlong"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "long long"
        javaName: "long"
        jniName: "jlong"
    }
    
    PrimitiveType{
        name: "quintptr"
        javaName: "long"
        jniName: "jlong"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "qintptr"
        javaName: "long"
        jniName: "jlong"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "qsizetype"
        javaName: "long"
        jniName: "jlong"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "short"
        javaName: "char"
        jniName: "jchar"
        preferredConversion: false
        preferredJavaType: false
    }
    
    PrimitiveType{
        name: "short"
        javaName: "short"
        jniName: "jshort"
    }
    
    PrimitiveType{
        name: "uint16_t"
        javaName: "short"
        jniName: "jshort"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "signed short"
        javaName: "short"
        jniName: "jshort"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "unsigned short"
        javaName: "short"
        jniName: "jshort"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "unsigned short int"
        javaName: "short"
        jniName: "jshort"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "char"
        javaName: "byte"
        jniName: "jbyte"
    }
    
    PrimitiveType{
        name: "signed char"
        javaName: "byte"
        jniName: "jbyte"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "unsigned char"
        javaName: "byte"
        jniName: "jbyte"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "std::byte"
        javaName: "byte"
        jniName: "jbyte"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "int"
        jniName: "jint"
    }
    
    PrimitiveType{
        name: "signed int"
        javaName: "int"
        jniName: "jint"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "uint"
        javaName: "int"
        jniName: "jint"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "ulong"
        javaName: "int"
        jniName: "jint"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "unsigned int"
        javaName: "int"
        jniName: "jint"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "unsigned"
        javaName: "int"
        jniName: "jint"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "signed long"
        javaName: "int"
        jniName: "jint"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "long"
        javaName: "int"
        jniName: "jint"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "unsigned long"
        javaName: "int"
        jniName: "jint"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "WId"
        javaName: "long"
        jniName: "jlong"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "Qt::HANDLE"
        javaName: "long"
        jniName: "jlong"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "QSocketDescriptor"
        javaName: "long"
        jniName: "jlong"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "QByteRef"
        javaName: "byte"
        jniName: "jbyte"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "QBitRef"
        javaName: "boolean"
        jniName: "jboolean"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "QBool"
        javaName: "boolean"
        jniName: "jboolean"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "char16_t"
        javaName: "char"
        jniName: "jchar"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "char32_t"
        javaName: "int"
        jniName: "jint"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "jobject"
        javaName: "java.lang.Object"
        jniName: "jobject"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "jstring"
        javaName: "java.lang.String"
        jniName: "jstring"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "_jobject"
        javaName: "java.lang.Object"
        jniName: "jobject"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "_jstring"
        javaName: "java.lang.String"
        jniName: "jstring"
        preferredConversion: false
    }
    
    PrimitiveType{
        name: "std::nullptr_t"
        javaName: "null"
        jniName: "std::nullptr_t"
        preferredConversion: false
    }
    
    Template{
        name: "core.multiply-devide-add-subtract"
        Text{content: "public final %TYPE multiply(double d) { operator_multiply_assign(d); return this; }\n"+
                      "public final %TYPE divide(double d) { operator_divide_assign(d); return this; }\n"+
                      "public final %TYPE add(%TYPE p) { operator_add_assign(p); return this; }\n"+
                      "public final %TYPE subtract(%TYPE p) { operator_subtract_assign(p); return this; }"}
    }
    
    TemplateType{
        name: "Stream"
        ModifyFunction{
            signature: "operator<<(long long)"
            Rename{
                to: "writeLong"
            }
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "operator<<(float)"
            Rename{
                to: "writeFloat"
            }
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "operator<<(double)"
            Rename{
                to: "writeDouble"
            }
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "operator>>(long long&)"
            Rename{
                to: "readLong"
            }
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "long"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "Q_UNUSED(__qt_return_value)\n"+
                                  "%out = __qt_%1;"}
                }
            }
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "long long %out = 0;"}
                }
            }
        }
        ModifyFunction{
            signature: "operator>>(float&)"
            Rename{
                to: "readFloat"
            }
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "float"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "Q_UNUSED(__qt_return_value)\n"+
                                  "%out = __qt_%1;"}
                }
            }
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "float %out = 0.f;"}
                }
            }
        }
        ModifyFunction{
            signature: "operator>>(double&)"
            Rename{
                to: "readDouble"
            }
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "double"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "Q_UNUSED(__qt_return_value)\n"+
                                  "%out = __qt_%1;"}
                }
            }
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "double %out = 0.0;"}
                }
            }
        }
    }
    
    GlobalFunction{
        signature: "qRegisterMetaType<T>(const char*)"
        remove: RemoveFlag.All
    }
    
    GlobalFunction{
        signature: "qRegisterMetaType<T>()"
        targetType: "QMetaType"
        Instantiation{
            proxyCall: "CoreAPI::registerMetaType"
            Argument{
                type: "QObject"
            }
            AddArgument{
                index: 1
                name: "clazz"
                type: "java.lang.Class<?>"
            }
            AddArgument{
                index: 2
                name: "instantiations"
                type: "io.qt.core.QMetaType..."
            }
        }
    }
    
    GlobalFunction{
        signature: "qMetaTypeId<T>()"
        targetType: "QMetaType"
        Instantiation{
            proxyCall: "CoreAPI::metaTypeId"
            Argument{
                type: "QObject"
            }
            AddArgument{
                index: 1
                name: "clazz"
                type: "java.lang.Class<?>"
            }
            AddArgument{
                index: 2
                name: "instantiations"
                type: "io.qt.core.QMetaType..."
            }
        }
    }
    
    
    Rejection{
        className: "QStringConverterBase::State"
        functionName: "reset"
    }

    Rejection{
        className: "QSequentialConstIterator"
    }
    
    Rejection{
        className: ""
        enumName: "QtJambiNativeID"
    }
    
    Rejection{
        className: "QNativeInterface::QAndroidApplication"
        functionName: "runOnAndroidMainThread"
    }
    
    Rejection{
        className: "std::string"
    }
    
    Rejection{
        className: "std::seed_seq"
    }
    
    Rejection{
        className: "function_ref"
    }
    
    Rejection{
        className: "QtPrivate::Deprecated_t"
    }
    
    Rejection{
        className: "QFutureSynchronizer"
    }
    
    Rejection{
        className: "JNIEnv_"
    }
    
    Rejection{
        className: "QJniEnvironment"
    }
    
    Rejection{
        className: "QJniObject"
    }
    
    Rejection{
        className: "JNIInvokeInterface_"
    }
    
    Rejection{
        className: "JNINativeInterface_"
    }
    
    Rejection{
        className: "ProcessOpenModeResult"
    }
    
    Rejection{
        className: "JavaVM_"
    }
    
    Rejection{
        className: "qt_clang_builtin_available_os_version_data"
    }
    
    Rejection{
        className: "_jthrowable"
    }
    
    Rejection{
        className: "_jstring"
    }
    
    Rejection{
        className: "_jshortArray"
    }
    
    Rejection{
        className: "_jobjectArray"
    }
    
    Rejection{
        className: "_jobject"
    }
    
    Rejection{
        className: "_jlongArray"
    }
    
    Rejection{
        className: "_jintArray"
    }
    
    Rejection{
        className: "_jfloatArray"
    }
    
    Rejection{
        className: "_jdoubleArray"
    }
    
    Rejection{
        className: "_jclass"
    }
    
    Rejection{
        className: "_jcharArray"
    }
    
    Rejection{
        className: "_jbyteArray"
    }
    
    Rejection{
        className: "_jbooleanArray"
    }
    
    Rejection{
        className: "_jarray"
    }
    
    Rejection{
        className: "QArgumentType"
    }
    
    Rejection{
        className: "QMetaObjectPrivate"
    }
    
    Rejection{
        className: "QStringView"
    }
    
    Rejection{
        className: "QFSFileEnginePrivate"
    }
    
    Rejection{
        className: "QMatrix"
    }
    
    Rejection{
        className: "QArrayData"
    }
    
    Rejection{
        className: "QTypedArrayData"
    }
    
    Rejection{
        className: "QArrayDataOps"
    }
    
    Rejection{
        className: "QArrayDataPointer"
    }
    
    Rejection{
        className: "QArrayDataPointerRef"
    }
    
    Rejection{
        className: "QStaticArrayData"
    }
    
    Rejection{
        className: "QStaticByteArrayData"
    }
    
    Rejection{
        className: "QStaticByteArrayMatcher"
    }
    
    Rejection{
        className: "QStaticByteArrayMatcherBase"
    }
    
    Rejection{
        className: "QStaticStringData"
    }
    
    Rejection{
        className: "QStringBuilderBase"
    }
    
    Rejection{
        className: "QStringBuilderCommon"
    }
    
    Rejection{
        className: "QStringDataPtr"
    }
    
    Rejection{
        className: "QSemaphoreReleaser"
    }
    
    Rejection{
        className: "QRandomGenerator64"
    }
    
    Rejection{
        className: "QKeyValueIterator"
    }
    
    Rejection{
        className: "QAtomicAdditiveType"
    }
    
    Rejection{
        className: "QBasicAtomicInteger"
    }
    
    Rejection{
        className: "QBigEndianStorageType"
    }
    
    Rejection{
        className: "QDateTime::Data"
    }
    
    Rejection{
        className: "QDateTime::ShortData"
    }
    
    Rejection{
        className: "QFileSystemEntry"
    }
    
    Rejection{
        className: "QFileSystemMetaData"
    }
    
    Rejection{
        className: "QMapDataBase"
    }
    
    Rejection{
        className: "QAnyStringView"
    }
    
    Rejection{
        className: "QUtf8StringView"
    }
    
    Rejection{
        className: "QMapNodeBase"
    }
    
    Rejection{
        className: "QPalette::Data"
    }
    
    Rejection{
        className: "QStringConverter::Interface"
    }
    
    Rejection{
        className: "QList::MemoryLayout"
    }
    
    Rejection{
        className: "QString::DataPointer"
    }
    
    Rejection{
        className: "QtPrivate::BindingEvaluationState"
    }
    
    Rejection{
        className: "QList"
        enumName: "MemoryLayout"
    }
    
    Rejection{
        className: "QPropertyObserverBase"
        enumName: "ObserverTag"
        since: 6
    }
    
    Rejection{
        className: "QReadWriteLock"
        functionName: "stateForWaitCondition"
    }
    
    Rejection{
        className: "QFactoryLoader"
        functionName: "library"
    }
    
    Rejection{
        className: "QByteArrayView"
        functionName: "m_data"
    }
    
    Rejection{
        className: "QBindingStorage"
        functionName: "status"
    }
    
    Rejection{
        className: "QtPrivate"
        functionName: "fulfillPromise"
    }
    
    Rejection{
        className: "QtPrivate"
        functionName: "warnIfContainerIsNotShared"
    }
    
    Rejection{
        className: "QNativeInterface::Private"
        functionName: "hasTypeInfo"
    }
    
    Rejection{
        className: "QString"
        functionName: "rightRef"
    }
    
    Rejection{
        className: "QString"
        functionName: "leftRef"
    }
    
    Rejection{
        className: "QString"
        functionName: "midRef"
    }
    
    Rejection{
        className: "QString"
        functionName: "splitRef"
    }
    
    Rejection{
        className: "QString"
        functionName: "sprintf"
    }
    
    Rejection{
        className: "QString"
        functionName: "asprintf"
    }
    
    Rejection{
        className: "QString"
        functionName: "vasprintf"
    }
    
    Rejection{
        className: "QString"
        functionName: "fromStdU32String"
    }
    
    Rejection{
        className: "QString"
        functionName: "crend"
    }
    
    Rejection{
        className: "QString"
        functionName: "normalized"
    }
    
    Rejection{
        className: "QString"
        functionName: "fromStdU16String"
    }
    
    Rejection{
        className: "QString"
        functionName: "fromWCharArray"
    }
    
    Rejection{
        className: "QString"
        functionName: "fromStdWString"
    }
    
    Rejection{
        className: "QString"
        functionName: "tokenize"
    }
    
    Rejection{
        className: "QString"
        functionName: "crbegin"
    }
    
    Rejection{
        className: "QString"
        functionName: "rbegin"
    }
    
    Rejection{
        className: "QString"
        functionName: "fromStdString"
    }
    
    Rejection{
        className: "QString"
        functionName: "rend"
    }
    
    Rejection{
        className: "QString"
        functionName: "toWCharArray"
    }
    
    Rejection{
        className: "QString"
        functionName: "toUInt"
    }
    
    Rejection{
        className: "QString"
        functionName: "toUShort"
    }
    
    Rejection{
        className: "QString"
        functionName: "toULong"
    }
    
    Rejection{
        className: "QString"
        functionName: "toULongLong"
    }
    
    Rejection{
        className: "QString"
        functionName: "toLong"
    }
    
    Rejection{
        className: "QString"
        functionName: "push_back"
    }
    
    Rejection{
        className: "QString"
        functionName: "push_front"
    }
    
    Rejection{
        className: "QString"
        enumName: "SplitBehavior"
        until: [5, 15]
    }
    
    Rejection{
        className: "QString::Null"
        until: [5, 15]
    }
    
    Rejection{
        className: "QList"
        functionName: "empty"
    }
    
    Rejection{
        className: "QList"
        functionName: "front"
    }
    
    Rejection{
        className: "QList"
        functionName: "pop_back"
    }
    
    Rejection{
        className: "QList"
        functionName: "pop_front"
    }
    
    Rejection{
        className: "QList"
        functionName: "push_back"
    }
    
    Rejection{
        className: "QList"
        functionName: "push_front"
    }
    
    Rejection{
        className: "QList"
        functionName: "back"
    }
    
    Rejection{
        className: "QList"
        functionName: "shrink_to_fit"
    }
    
    Rejection{
        className: "QQueue"
        functionName: "empty"
    }
    
    Rejection{
        className: "QQueue"
        functionName: "front"
    }
    
    Rejection{
        className: "QQueue"
        functionName: "pop_back"
    }
    
    Rejection{
        className: "QQueue"
        functionName: "pop_front"
    }
    
    Rejection{
        className: "QQueue"
        functionName: "push_back"
    }
    
    Rejection{
        className: "QQueue"
        functionName: "push_front"
    }
    
    Rejection{
        className: "QQueue"
        functionName: "back"
    }
    
    Rejection{
        className: "QQueue"
        functionName: "shrink_to_fit"
    }
    
    Rejection{
        className: "QJsonObject"
        functionName: "empty"
    }
    
    Rejection{
        className: "QJsonArray"
        functionName: "empty"
    }
    
    Rejection{
        className: "QJsonArray"
        functionName: "pop_back"
    }
    
    Rejection{
        className: "QJsonArray"
        functionName: "pop_front"
    }
    
    Rejection{
        className: "QJsonArray"
        functionName: "push_back"
    }
    
    Rejection{
        className: "QJsonArray"
        functionName: "push_front"
    }
    
    Rejection{
        className: "QCborArray"
        functionName: "empty"
    }
    
    Rejection{
        className: "QCborArray"
        functionName: "pop_back"
    }
    
    Rejection{
        className: "QCborArray"
        functionName: "pop_front"
    }
    
    Rejection{
        className: "QCborArray"
        functionName: "push_back"
    }
    
    Rejection{
        className: "QCborArray"
        functionName: "push_front"
    }
    
    Rejection{
        className: "QCborArray"
        functionName: "erase"
    }
    
    Rejection{
        className: "QCborNegativeInteger"
    }
    
    Rejection{
        className: "QChar::SpecialCharacter"
    }
    
    Rejection{
        className: "QSet::const_iterator"
    }
    
    Rejection{
        className: "QSet"
        functionName: "empty"
    }
    
    Rejection{
        className: "QCborArray::Iterator"
    }
    
    Rejection{
        className: "QCborMap::Iterator"
    }
    
    Rejection{
        className: "QHash::iterator"
    }
    
    Rejection{
        className: "QHash::key_iterator"
    }
    
    Rejection{
        className: "QHash"
        functionName: "empty"
    }
    
    Rejection{
        className: "QLinkedList::iterator"
    }
    
    Rejection{
        className: "QObjectPrivate"
    }
    
    Rejection{
        className: "QAbstractItemModelPrivate"
    }
    
    Rejection{
        className: "QByteArray::DataPointer"
    }
    
    Rejection{
        className: "Qt::Initialization"
    }
    
    Rejection{
        className: "FILE"
    }
    
    Rejection{
        className: "QLinkedList"
        functionName: "empty"
    }
    
    Rejection{
        className: "QLinkedList"
        functionName: "back"
    }
    
    Rejection{
        className: "QLinkedList"
        functionName: "front"
    }
    
    Rejection{
        className: "QLinkedList"
        functionName: "push_back"
    }
    
    Rejection{
        className: "QLinkedList"
        functionName: "push_front"
    }
    
    Rejection{
        className: "QLinkedList"
        functionName: "pop_back"
    }
    
    Rejection{
        className: "QLinkedList"
        functionName: "pop_front"
    }
    
    Rejection{
        className: "QFutureInterfaceBase"
        functionName: "resultStoreBase"
    }
    
    Rejection{
        className: "QFutureInterfaceBase"
        functionName: "reportException"
    }
    
    Rejection{
        className: "QFutureInterfaceBase"
        functionName: "exceptionStore"
    }
    
    Rejection{
        className: "QList::iterator"
    }
    
    Rejection{
        className: "QMap::iterator"
    }
    
    Rejection{
        className: "QMap::key_iterator"
    }
    
    Rejection{
        className: "QMap"
        functionName: "empty"
    }
    
    Rejection{
        className: "QSpecialInteger"
    }
    
    Rejection{
        className: "QScopeGuard"
    }
    
    Rejection{
        className: ""
        enumName: "QCborNegativeInteger"
    }
    
    Rejection{
        className: "QString"
        enumName: "NormalizationForm"
    }
    
    Rejection{
        className: "QSysInfo"
        enumName: "Sizes"
    }
    
    Rejection{
        className: "QSysInfo"
        enumName: "MacVersion"
    }
    
    Rejection{
        className: "QSysInfo"
        enumName: "WinVersion"
    }
    
    Rejection{
        className: "QListSpecialMethods"
    }
    
    Rejection{
        className: "QLittleEndianStorageType"
    }
    
    Rejection{
        className: "QMetaTypeIdQObject"
    }
    
    Rejection{
        className: "QGenericAtomicOps"
    }
    
    Rejection{
        className: "QVector::AlignmentDummy"
    }
    
    Rejection{
        className: "QVector"
        functionName: "back"
    }
    
    Rejection{
        className: "QVector"
        functionName: "empty"
    }
    
    Rejection{
        className: "QVector"
        functionName: "front"
    }
    
    Rejection{
        className: "QVector"
        functionName: "push_back"
    }
    
    Rejection{
        className: "QVector"
        functionName: "push_front"
    }
    
    Rejection{
        className: "QVector"
        functionName: "pop_back"
    }
    
    Rejection{
        className: "QVector"
        functionName: "pop_front"
    }
    
    Rejection{
        className: "QVector"
        functionName: "freeData"
    }
    
    Rejection{
        className: "QVector"
        functionName: "shrink_to_fit"
    }
    
    Rejection{
        className: "QStack"
        functionName: "back"
    }
    
    Rejection{
        className: "QStack"
        functionName: "empty"
    }
    
    Rejection{
        className: "QStack"
        functionName: "front"
    }
    
    Rejection{
        className: "QStack"
        functionName: "push_back"
    }
    
    Rejection{
        className: "QStack"
        functionName: "push_front"
    }
    
    Rejection{
        className: "QStack"
        functionName: "pop_back"
    }
    
    Rejection{
        className: "QStack"
        functionName: "pop_front"
    }
    
    Rejection{
        className: "QStack"
        functionName: "shrink_to_fit"
    }
    
    Rejection{
        className: "QRegularExpressionMatchIterator"
        functionName: "begin"
    }
    
    Rejection{
        className: "QRegularExpressionMatchIterator"
        functionName: "end"
    }
    
    Rejection{
        className: "QUrlTwoFlags"
    }
    
    Rejection{
        className: "QMetaType::Constructor"
    }
    
    Rejection{
        className: "QMetaType::Creator"
    }
    
    Rejection{
        className: "QMetaType::Deleter"
    }
    
    Rejection{
        className: "QMetaType::Destructor"
    }
    
    Rejection{
        className: "QMetaType::LoadOperator"
    }
    
    Rejection{
        className: "QMetaType::SaveOperator"
    }
    
    Rejection{
        className: "QMetaType::TypedConstructor"
    }
    
    Rejection{
        className: "QMetaType::TypedDestructor"
    }
    
    Rejection{
        className: "QMetaType::MutableViewFunction"
    }
    
    Rejection{
        className: "QAbstractAnimationPrivate"
    }
    
    Rejection{
        className: "QAbstractButtonPrivate"
    }
    
    Rejection{
        className: "QAbstractEventDispatcherPrivate"
    }
    
    Rejection{
        className: "*"
        functionName: "d_func"
    }
    
    Rejection{
        className: "*"
        functionName: "data_ptr"
    }
    
    Rejection{
        className: "QBasicMutex"
        functionName: "try_lock"
    }
    
    Rejection{
        className: "QBasicMutex"
        functionName: "fastTryUnlock"
    }
    
    Rejection{
        className: "QBasicMutex"
        functionName: "fastTryLock"
    }
    
    Rejection{
        className: "QBasicMutex"
        functionName: "dummyLocked"
    }
    
    Rejection{
        className: "QMutex"
        functionName: "try_lock_for"
    }
    
    Rejection{
        className: "QMutex"
        functionName: "try_lock_until"
    }
    
    
    Rejection{
        className: "*"
        fieldName: "d_ptr"
    }
    
    Rejection{
        className: "*"
        fieldName: "d"
    }
    
    Rejection{
        className: "*"
        fieldName: "m_reserved"
    }
    
    Rejection{
        className: "*"
        functionName: "qt_getEnumMetaObject"
    }
    
    Rejection{
        className: "*"
        functionName: "qt_getEnumName"
    }
    
    Rejection{
        className: "*"
        functionName: "operator typename *"
    }
    
    Rejection{
        className: "*"
        functionName: "operator QVariant"
    }
    
    Rejection{
        className: "*"
        functionName: "operator_cast_QVariant"
    }
    
    Rejection{
        className: "QVector"
        functionName: "operator="
    }
    
    Rejection{
        className: "QStack"
        functionName: "operator="
    }
    
    Rejection{
        className: "QMap"
        functionName: "operator="
    }
    
    Rejection{
        className: "QMap"
        functionName: "operator[]"
    }
    
    Rejection{
        className: "QHash"
        functionName: "operator="
    }
    
    Rejection{
        className: "QHash"
        functionName: "operator[]"
    }
    
    Rejection{
        className: "QHash"
        functionName: "load_factor"
    }
    
    Rejection{
        className: "QHash"
        functionName: "max_load_factor"
    }
    
    Rejection{
        className: "QHash"
        functionName: "bucket_count"
    }
    
    Rejection{
        className: "QHash"
        functionName: "max_bucket_count"
    }
    
    Rejection{
        className: "QMultiMap"
        functionName: "constFind"
    }
    
    Rejection{
        className: "QMultiMap"
        functionName: "operator[]"
    }
    
    Rejection{
        className: "QMultiHash"
        functionName: "operator="
    }
    
    Rejection{
        className: "QMultiHash"
        functionName: "operator[]"
    }
    
    Rejection{
        className: "QMultiHash"
        functionName: "constFind"
    }
    
    Rejection{
        className: "QMultiHash"
        functionName: "load_factor"
    }
    
    Rejection{
        className: "QMultiHash"
        functionName: "max_load_factor"
    }
    
    Rejection{
        className: "QMultiHash"
        functionName: "bucket_count"
    }
    
    Rejection{
        className: "QMultiHash"
        functionName: "max_bucket_count"
    }
    
    Rejection{
        className: "QMultiHash"
        functionName: "equal_range"
    }
    
    Rejection{
        className: "QDeadlineTimer"
        functionName: "_q_data"
    }

    Rejection{
        className: "QDeadlineTimer"
        functionName: "remainingTimeAsDuration"
    }
    
    Rejection{
        className: "QtPrivate"
        functionName: "qTryMetaTypeInterfaceForType"
    }
    
    Rejection{
        className: "QtPrivate"
        functionName: "qMetaTypeInterfaceForType"
    }
    
    Rejection{
        className: "QtPrivate"
        functionName: "qMakeStringPrivate"
    }
    
    Rejection{
        className: "QtPrivate"
        functionName: "qMakeForeachContainer"
    }
    
    Rejection{
        className: "Qt::QtMsgType"
    }
    
    Rejection{
        className: "Qt::Disambiguated_t"
    }
    
    Rejection{
        className: ""
        enumName: "QtValidLicenseForTestModule"
    }
    
    Rejection{
        className: "QTextCodecPlugin"
        functionName: "create(const QString &)"
    }
    
    Rejection{
        className: "QTextCodecPlugin"
        functionName: "keys()const"
    }
    
    Rejection{
        className: "*"
        enumName: "__codecvt_result"
    }
    
    Rejection{
        className: "*"
        enumName: "enum_1"
    }
    
    Rejection{
        className: "*"
        enumName: "enum_2"
    }
    
    Rejection{
        className: "*"
        enumName: "enum_3"
    }
    
    Rejection{
        className: "*"
        enumName: "enum_4"
    }
    
    Rejection{
        className: "*"
        enumName: "enum_5"
    }
    
    Rejection{
        className: "*"
        enumName: "enum_6"
    }
    
    Rejection{
        className: ""
        enumName: "QtValidLicenseForDBusModule"
    }
    
    Rejection{
        className: ""
        enumName: "QtValidLicenseForSqlModule"
    }
    
    Rejection{
        className: ""
        enumName: "QtValidLicenseForOpenGLModule"
    }
    
    Rejection{
        className: ""
        enumName: "QtValidLicenseForXmlModule"
    }
    
    Rejection{
        className: ""
        enumName: "QtValidLicenseForXmlPatternsModule"
    }
    
    Rejection{
        className: ""
        enumName: "QtValidLicenseForActiveQtModule"
    }
    
    Rejection{
        className: ""
        enumName: "QtValidLicenseForCoreModule"
    }
    
    Rejection{
        className: ""
        enumName: "QtValidLicenseForQt3SupportLightModule"
    }
    
    Rejection{
        className: ""
        enumName: "QtValidLicenseForQt3SupportModule"
    }
    
    Rejection{
        className: ""
        enumName: "QtValidLicenseForNetworkModule"
    }
    
    Rejection{
        className: ""
        enumName: "QtValidLicenseForSvgModule"
    }
    
    Rejection{
        className: ""
        enumName: "QtValidLicenseForGuiModule"
    }
    
    Rejection{
        className: ""
        enumName: "QtValidLicenseForScriptModule"
    }
    
    Rejection{
        className: ""
        enumName: "QtValidLicenseForHelpModule"
    }
    
    Rejection{
        className: ""
        enumName: "QtValidLicenseForScriptToolsModule"
    }
    
    Rejection{
        className: ""
        enumName: "QtValidLicenseForMultimediaModule"
    }
    
    Rejection{
        className: ""
        enumName: "QtValidLicenseForOpenVGModule"
    }
    
    Rejection{
        className: ""
        enumName: "QtValidLicenseForDeclarativeModule"
    }
    
    Rejection{
        className: ""
        functionName: "qJsonFromRawLibraryMetaData"
    }
    
    Rejection{
        className: ""
        functionName: "qt_getQtMetaObject"
        until: [5, 15]
    }
    
    Rejection{
        className: ""
        functionName: "qMapLessThanKey"
        until: [5, 15]
    }
    
    Rejection{
        className: ""
        functionName: "qRegisterMetaTypeStreamOperators"
        until: [5, 15]
    }
    
    Rejection{
        className: ""
        functionName: "qLowerBound"
        until: [5, 15]
    }
    
    Rejection{
        className: ""
        functionName: "qIsTrivial"
        until: [5, 15]
    }
    
    Rejection{
        className: ""
        functionName: "qIsRelocatable"
        until: [5, 15]
    }
    
    Rejection{
        className: ""
        functionName: "qFind"
        until: [5, 15]
    }
    
    Rejection{
        className: ""
        functionName: "qFill"
        until: [5, 15]
    }
    
    Rejection{
        className: ""
        functionName: "qBinaryFind"
        until: [5, 15]
    }
    
    Rejection{
        className: ""
        functionName: "qCopyBackward"
        until: [5, 15]
    }
    
    Rejection{
        className: ""
        functionName: "qCopy"
        until: [5, 15]
    }
    
    Rejection{
        className: ""
        functionName: "qCount"
        until: [5, 15]
    }
    
    Rejection{
        className: ""
        functionName: "qSort"
        until: [5, 15]
    }
    
    Rejection{
        className: ""
        functionName: "qStableSort"
        until: [5, 15]
    }
    
    Rejection{
        className: ""
        functionName: "qToVoidFuture"
        until: [5, 15]
    }
    
    Rejection{
        className: ""
        functionName: "qUpperBound"
        until: [5, 15]
    }
    
    Rejection{
        className: ""
        functionName: "qVariantFromValue"
        until: [5, 15]
    }
    
    Rejection{
        className: ""
        functionName: "qVariantSetValue"
        until: [5, 15]
    }
    
    Rejection{
        className: "QtFuture"
        functionName: "makeExceptionalFuture"
    }
    
    Rejection{
        className: "QtFuture"
        functionName: "makeReadyFuture"
    }
    
    Rejection{
        className: "QVariant::Private"
    }
    
    Rejection{
        className: "QVariant::PrivateShared"
    }
    
    Rejection{
        className: "QVariantAnimation::Interpolator"
    }
    
    Rejection{
        className: "QVariantAnimation"
        functionName: "qRegisterAnimationInterpolator"
    }
    
    Rejection{
        className: "*"
        functionName: "qRegisterAnimationInterpolator"
    }
    
    Rejection{
        className: "QLocalePrivate"
    }
    
    Rejection{
        className: "QLocale"
        functionName: "d"
    }
    
    Rejection{
        className: "QVersionNumber"
        functionName: "Q_STATIC_ASSERT"
    }
    
    Rejection{
        className: "QRunnable"
        functionName: "create"
    }
    
    Rejection{
        className: "QProcess"
        functionName: "setupChildProcess"
        since: 6
    }
    
    Rejection{
        className: "QLoggingCategoryMacroHolder"
        since: [6, 3]
    }
    
    Rejection{
        className: "QVLABase"
        since: [6, 3]
    }
    
    Rejection{
        className: "QVLABaseBase"
        since: [6, 3]
    }
    
    Rejection{
        className: "QVLAStorage"
        since: [6, 3]
    }
    
    Rejection{
        className: "QtFuture::WhenAnyResult"
        since: [6, 3]
    }
    
    Rejection{
        className: "Qt"
        enumName: "Modifier"
    }
    
    Rejection{
        className: "Qt::Modifiers"
    }
    
    Rejection{
        className: "QEnableSharedFromThis"
    }
    
    Rejection{
        className: "QGenericArgument"
    }
    
    Rejection{
        className: "QGenericReturnArgument"
    }
    
    Rejection{
        className: "QWeakPointer"
    }
    
    Rejection{
        className: "QMdi"
    }
    
    Rejection{
        className: "stdext"
    }
    
    Rejection{
        className: "QAlgorithmsPrivate"
    }
    
    Rejection{
        className: "QAtomic"
    }
    
    Rejection{
        className: "QAtomicInteger"
    }
    
    Rejection{
        className: "QAtomicPointer"
    }
    
    Rejection{
        className: "QAtomicInt"
    }
    
    Rejection{
        className: "QBasicAtomicInt"
    }
    
    Rejection{
        className: "QBasicAtomic"
    }
    
    Rejection{
        className: "QBasicAtomicPointer"
    }
    
    Rejection{
        className: "QScopedPointer"
    }
    
    Rejection{
        className: "QScopedArrayPointer"
    }
    
    Rejection{
        className: "QScopedPointerObjectDeleteLater"
    }
    
    Rejection{
        className: "QScopedPointerArrayDeleter"
    }
    
    Rejection{
        className: "QScopedPointerDeleter"
    }
    
    Rejection{
        className: "QScopedPointerPodDeleter"
    }
    
    Rejection{
        className: "QScopedPointerSharedDeleter"
    }
    
    Rejection{
        className: "QScopedSharedPointer"
    }
    
    Rejection{
        className: "QScopedValueRollback"
    }
    
    Rejection{
        className: "QCustomScopedPointer"
    }
    
    Rejection{
        className: "QStringBuilder"
    }
    
    Rejection{
        className: "QProcess::CreateProcessArguments"
    }
    
    Rejection{
        className: "QOverload"
    }
    
    Rejection{
        className: "QNonConstOverload"
    }
    
    Rejection{
        className: "QConstOverload"
    }
    
    Rejection{
        className: "Null"
    }
    
    Rejection{
        className: "std::chrono::milliseconds"
    }
    
    Rejection{
        className: "std::filesystem::path"
    }
    
    Rejection{
        className: "std::u16string"
    }
    
    Rejection{
        className: "std::u32string"
    }
    
    Rejection{
        className: "std::wstring"
    }
    
    Rejection{
        className: "QPropertyBindingPrivate"
    }
    
    Rejection{
        className: "QAbstractConcatenable"
    }
    
    Rejection{
        className: "QBitRef"
    }
    
    Rejection{
        className: "QCache"
    }
    
    Rejection{
        className: "QContiguousCache"
    }
    
    Rejection{
        className: "QContiguousCacheData"
    }
    
    Rejection{
        className: "QContiguousCacheTypedData"
    }
    
    Rejection{
        className: "QCharRef"
    }
    
    Rejection{
        className: "QNoDebug"
    }
    
    Rejection{
        className: "QExplicitlySharedDataPointer"
    }
    
    Rejection{
        className: "QFlag"
    }
    
    Rejection{
        className: "QFlags"
    }
    
    Rejection{
        className: "QForeachContainer"
    }
    
    Rejection{
        className: "QForeachContainerBase"
    }
    
    Rejection{
        className: "QGlobalStatic"
    }
    
    Rejection{
        className: "QHashData"
    }
    
    Rejection{
        className: "QHashDummyNode"
    }
    
    Rejection{
        className: "QHashDummyValue"
    }
    
    Rejection{
        className: "QHashIterator"
    }
    
    Rejection{
        className: "QHashNode"
    }
    
    Rejection{
        className: "QInternal"
    }
    
    Rejection{
        className: "QIncompatibleFlag"
    }
    
    Rejection{
        className: "QLinkedListData"
    }
    
    Rejection{
        className: "QLinkedListIterator"
    }
    
    Rejection{
        className: "QLinkedListNode"
    }
    
    Rejection{
        className: "QListData"
    }
    
    Rejection{
        className: "QListIterator"
    }
    
    Rejection{
        className: "QMapNode"
    }
    
    Rejection{
        className: "QMapPayloadNode"
    }
    
    Rejection{
        className: "QMapData"
    }
    
    Rejection{
        className: "QMapIterator"
    }
    
    Rejection{
        className: "QMetaTypeId"
    }
    
    Rejection{
        className: "QMetaClassInfo"
    }
    
    Rejection{
        className: "QMutableHashIterator"
    }
    
    Rejection{
        className: "QMutableLinkedListIterator"
    }
    
    Rejection{
        className: "QMutableListIterator"
    }
    
    Rejection{
        className: "QMutableMapIterator"
    }
    
    Rejection{
        className: "QMutableVectorIterator"
    }
    
    Rejection{
        className: "QMutexLocker"
    }
    
    Rejection{
        className: "QNoImplicitBoolCast"
    }
    
    Rejection{
        className: "QObjectData"
    }
    
    Rejection{
        className: "QObject"
        fieldName: "staticQtMetaObject"
    }
    
    Rejection{
        className: "QObjectUserData"
    }
    
    Rejection{
        className: "QPointer"
    }
    
    Rejection{
        className: "QReadLocker"
    }
    
    Rejection{
        className: "QSetIterator"
    }
    
    Rejection{
        className: "QSharedData"
    }
    
    Rejection{
        className: "QSharedDataPointer"
    }
    
    Rejection{
        className: "QTextStreamManipulator"
    }
    
    Rejection{
        className: "QTextStreamFunction"
    }
    
    Rejection{
        className: "QTSMFI"
    }
    
    Rejection{
        className: "QTSMFC"
    }
    
    Rejection{
        className: "QtCleanUpFunction"
    }
    
    Rejection{
        className: "qInternalCallback"
    }
    
    Rejection{
        className: "QtStartUpFunction"
    }
    
    Rejection{
        className: "QtPluginInstanceFunction"
    }
    
    Rejection{
        className: "QtPluginMetaDataFunction"
    }
    
    Rejection{
        className: "QThreadStorageData"
    }
    
    Rejection{
        className: "QTypeInfo"
    }
    
    Rejection{
        className: "QTypeInfoQuery"
    }
    
    Rejection{
        className: "QTypeInfoMerger"
    }
    
    Rejection{
        className: "QTypeInfo"
        enumName: "enum_1"
    }
    
    Rejection{
        className: "QTypeInfo"
        enumName: "enum_2"
    }
    
    Rejection{
        className: "QTimeZone"
        enumName: "enum_1"
    }
    
    Rejection{
        className: "QArrayData"
        enumName: "AllocationOption"
    }
    
    Rejection{
        className: "QVFbKeyData"
    }
    
    Rejection{
        className: "QVariantComparisonHelper"
    }
    
    Rejection{
        className: "QVectorData"
    }
    
    Rejection{
        className: "QVectorIterator"
    }
    
    Rejection{
        className: "QVectorTypedData"
    }
    
    Rejection{
        className: "QWriteLocker"
    }
    
    Rejection{
        className: "qGreater"
    }
    
    Rejection{
        className: "qLess"
    }
    
    Rejection{
        className: "std"
    }
    
    Rejection{
        className: "QByteArray::Data"
    }
    
    Rejection{
        className: "QIntForType"
    }
    
    Rejection{
        className: "QList::Node"
    }
    
    Rejection{
        className: "QList::Data"
    }
    
    Rejection{
        className: "QMetaTypeId2"
    }
    
    Rejection{
        className: "QMutableSetIterator"
    }
    
    Rejection{
        className: "QSubString"
    }
    
    Rejection{
        className: "QUintForType"
    }
    
    Rejection{
        className: "QByteArrayMatcher::Data"
    }
    
    Rejection{
        className: "QStringMatcher::Data"
    }

    Rejection{
        className: "QLatin1StringMatcher"
    }
    
    Rejection{
        className: "StringBuilder"
    }
    
    Rejection{
        className: "QConcatenable"
    }
    
    Rejection{
        className: "QLatin1Literal"
    }
    
    Rejection{
        className: "QIntegerForSizeof"
    }
    
    Rejection{
        className: "QLocale::Data"
    }

    Rejection{
        className: "QMetaMethod::Data"
    }
    
    Rejection{
        className: "QGlobalStaticDeleter"
    }
    
    Rejection{
        className: "QVarLengthArray"
    }
    
    Rejection{
        className: "_Revbidit"
    }
    
    Rejection{
        className: "_complex"
    }
    
    Rejection{
        className: "_exception"
    }
    
    Rejection{
        className: "_iobuf"
    }
    
    Rejection{
        className: "_stat"
    }
    
    Rejection{
        className: "_wfinddata_t"
    }
    
    Rejection{
        className: "exception"
    }
    
    Rejection{
        className: "istreambuf_iterator"
    }
    
    Rejection{
        className: "ostreambuf_iterator"
    }
    
    Rejection{
        className: "reverse_bidirectional_iterator"
    }
    
    Rejection{
        className: "reverse_iterator"
    }
    
    Rejection{
        className: "stat"
    }
    
    Rejection{
        className: "tm"
    }
    
    Rejection{
        className: "_IO_FILE"
    }
    
    Rejection{
        className: "_IO_marker"
    }
    
    Rejection{
        className: "__exception"
    }
    
    Rejection{
        className: "drand48_data"
    }
    
    Rejection{
        className: "random_data"
    }
    
    Rejection{
        className: "timespec"
    }
    
    Rejection{
        className: "timeval"
    }
    
    Rejection{
        className: "QJsonPrivate::Data"
    }
    
    Rejection{
        className: "QByteArrayDataPtr"
    }
    
    Rejection{
        className: "Data::AllocationOptions"
    }
    
    Rejection{
        className: "QJsonValuePtr"
    }
    
    Rejection{
        className: "QJsonValueRefPtr"
    }
    
    Rejection{
        className: "QMimeTypePrivate"
    }
    
    Rejection{
        className: "QAtomicOpsSupport"
        since: [6, 2]
    }
    
    Rejection{
        className: "QCalendar::SystemId"
        since: [6, 2]
    }
    
    Rejection{
        className: "QFuture::const_iterator"
    }
    
    Rejection{
        className: "QNativeInterface::NativeInterface"
    }
    
    Rejection{
        className: "QNativeInterface::has_type_info"
    }
    
    Rejection{
        className: "Qt"
        enumName: "Initialization"
    }
    
    Rejection{
        className: "QFuture"
        functionName: "unwrap"
    }
    
    Rejection{
        className: "QFuture"
        functionName: "then"
    }
    
    Rejection{
        className: "QFuture"
        functionName: "d"
    }
    
    Rejection{
        className: "QHash"
        functionName: "equal_range"
    }
    
    Rejection{
        className: "QMap"
        functionName: "equal_range"
    }
    
    Rejection{
        className: "QAbstractEventDispatcher"
        functionName: "filterEvent"
    }
    
    Rejection{
        className: "QAbstractEventDispatcher"
        functionName: "filterNativeEvent"
    }
    
    Rejection{
        className: "QAbstractEventDispatcher"
        functionName: "setEventFilter"
    }
    
    Rejection{
        className: "QCoreApplication"
        functionName: "compressEvent"
    }
    
    Rejection{
        className: "QCoreApplication"
        functionName: "eventFilter"
    }
    
    Rejection{
        className: "QCoreApplication"
        functionName: "filterEvent"
    }
    
    Rejection{
        className: "QCoreApplication"
        functionName: "filterNativeEvent"
    }
    
    Rejection{
        className: "QCoreApplication"
        functionName: "setEventFilter"
    }
    
    Rejection{
        className: "QCoreApplication"
        functionName: "nativeInterface"
        since: [6, 2]
    }
    
    Rejection{
        className: "QCoreApplication"
        enumName: "enum_1"
    }
    
    
    Rejection{
        className: "QRandomGenerator"
        functionName: "bounded"
    }
    
    Rejection{
        className: "QFile"
        functionName: "setDecodingFunction"
    }
    
    Rejection{
        className: "QFile"
        functionName: "setEncodingFunction"
    }
    
    Rejection{
        className: "QObject"
        functionName: "setUserData"
    }
    
    Rejection{
        className: "QObject"
        functionName: "userData"
    }
    
    Rejection{
        className: "QObject"
        functionName: "connect"
    }
    
    Rejection{
        className: "QObject"
        functionName: "disconnect"
    }
    
    Rejection{
        className: "QObject"
        functionName: "registerUserData"
    }
    
    Rejection{
        className: "QObject"
        functionName: "connectImpl"
    }
    
    Rejection{
        className: "QObject"
        functionName: "connect_functor"
    }
    
    Rejection{
        className: "QObject"
        functionName: "disconnectImpl"
    }
    
    Rejection{
        className: "QTimer"
        functionName: "singleShot"
    }
    
    Rejection{
        className: "QProcess"
        functionName: "pid"
    }
    
    Rejection{
        className: "QProcess"
        functionName: "childProcessModifier"
        since: 6
    }
    
    Rejection{
        className: "QProcess"
        functionName: "setChildProcessModifier"
        since: 6
    }
    
    Rejection{
        className: "QProcess"
        functionName: "createProcessArgumentsModifier"
        since: 6
    }
    
    Rejection{
        className: "QProcess"
        functionName: "setCreateProcessArgumentsModifier"
        since: 6
    }
    
    Rejection{
        className: "QProcess"
        functionName: "nativeArguments"
        since: 6
    }
    
    Rejection{
        className: "QProcess"
        functionName: "setNativeArguments"
        since: 6
    }
    
    Rejection{
        className: "QProcess::CreateProcessArguments"
        since: 6
    }
    
    Rejection{
        className: "QEvent::PointerEventTag"
        since: 6
    }
    
    Rejection{
        className: "QEvent::InputEventTag"
        since: 6
    }
    
    Rejection{
        className: "QEvent::SinglePointEventTag"
        since: 6
    }
    
    Rejection{
        className: "QNativeInterface::Private::NativeInterface"
        since: 6
    }
    
    Rejection{
        className: "QNativeInterface::Private::TypeInfo"
        since: 6
    }
    
    Rejection{
        className: "QNativeInterface::Private::has_type_info"
        since: 6
    }
    
    Rejection{
        className: "QNativeInterface::QAndroidApplication::TypeInfo"
        since: 6
    }
    
    Rejection{
        className: "QMetaType"
        functionName: "registerMutableViewFunction"
        since: 6
    }
    
    Rejection{
        className: "QMetaType"
        functionName: "unregisterMutableViewFunction"
        since: 6
    }
    
    Rejection{
        className: "QMetaType"
        functionName: "view"
        since: 6
    }
    
    Rejection{
        className: "QMetaType"
        functionName: "iface"
        since: 6
    }
    
    Rejection{
        className: "QPluginParsedMetaData"
        functionName: "parse"
        since: [6, 3]
    }
    
    Rejection{
        className: "QPluginParsedMetaData"
        functionName: "value"
        since: [6, 3]
    }
    
    Rejection{
        className: "QFutureInterfaceBase"
        functionName: "get"
        since: [6, 3]
    }
    
    Rejection{
        className: "QByteArrayView"
        functionName: "back"
    }
    
    Rejection{
        className: "QByteArrayView"
        functionName: "front"
    }
    
    Rejection{
        className: "QByteArrayView"
        functionName: "rbegin"
    }
    
    Rejection{
        className: "QByteArrayView"
        functionName: "rend"
    }
    
    Rejection{
        className: "QByteArrayView"
        functionName: "cend"
    }
    
    Rejection{
        className: "QByteArrayView"
        functionName: "cbegin"
    }
    
    Rejection{
        className: "QByteArrayView"
        functionName: "crend"
    }
    
    Rejection{
        className: "QByteArrayView"
        functionName: "crbegin"
    }
    
    Rejection{
        className: "QByteArrayView"
        functionName: "empty"
    }
    
    Rejection{
        className: "QByteArray"
        functionName: "back"
    }
    
    Rejection{
        className: "QByteArray"
        functionName: "front"
    }
    
    Rejection{
        className: "QByteArray"
        functionName: "rbegin"
    }
    
    Rejection{
        className: "QByteArray"
        functionName: "rend"
    }
    
    Rejection{
        className: "QByteArray"
        functionName: "cend"
    }
    
    Rejection{
        className: "QByteArray"
        functionName: "cbegin"
    }
    
    Rejection{
        className: "QByteArray"
        functionName: "crend"
    }
    
    Rejection{
        className: "QByteArray"
        functionName: "crbegin"
    }
    
    Rejection{
        className: "QByteArray"
        functionName: "empty"
    }
    
    Rejection{
        className: "QByteArray"
        functionName: "erase"
    }
    
    Rejection{
        className: "QByteArray"
        functionName: "fromStdString"
    }
    
    Rejection{
        className: "QByteArray"
        functionName: "reallocData"
    }
    
    Rejection{
        className: "QByteArray"
        functionName: "reallocGrowData"
    }
    
    Rejection{
        className: "QAbstractEventDispatcher"
        functionName: "installNativeEventFilter"
    }
    
    Rejection{
        className: "QAbstractEventDispatcher"
        functionName: "removeNativeEventFilter"
    }
    
    Rejection{
        className: "QCborContainerPrivate"
    }
    
    Rejection{
        className: "QAbstractFileEnginePrivate"
    }
    
    Rejection{
        className: "QException"
    }
    
    Rejection{
        className: "QUnhandledException"
    }
    
    Rejection{
        className: "QMessageLogger"
    }
    
    Rejection{
        className: "QAbstractNativeEventFilter"
    }
    
    Rejection{
        className: "Qt"
        functionName: "codecForHtml"
    }
    
    Rejection{
        className: "Qt"
        functionName: "mightBeRichText"
    }
    
    Rejection{
        className: "Qt"
        functionName: "escape"
    }
    
    Rejection{
        className: "Qt"
        functionName: "convertFromPlainText"
    }
    
    Rejection{
        className: "Qt"
        functionName: "makePropertyBinding"
    }
    
    Rejection{
        className: "Qt"
        enumName: "Modifiers"
    }
    
    Rejection{
        className: "QFSFileEnginePrivate"
    }
    
    
    Rejection{
        className: "QAbstractFileEngine"
        functionName: "extension"
    }
    
    Rejection{
        className: "QAbstractFileEngine"
        functionName: "supportsExtension"
    }
    
    Rejection{
        className: "QFSFileEngine"
        functionName: "extension"
    }
    
    Rejection{
        className: "QFSFileEngine"
        functionName: "supportsExtension"
    }
    
    
    Rejection{
        className: "QAbstractFileEngine"
        enumName: "Extension"
    }
    
    Rejection{
        className: "QAbstractFileEngine::ExtensionOption"
    }
    
    Rejection{
        className: "QAbstractFileEngine::ExtensionReturn"
    }
    
    Rejection{
        className: "QAbstractFileEngine::MapExtensionOption"
    }
    
    Rejection{
        className: "QAbstractFileEngine::MapExtensionReturn"
    }
    
    Rejection{
        className: "QAbstractFileEngine::UnMapExtensionOption"
    }
    
    Rejection{
        className: "QSharedPointer"
        functionName: "*"
    }
    
    Rejection{
        className: "QWeakPointer"
        functionName: "*"
    }
    
    Rejection{
        className: "QModelRoleData"
        functionName: "setData"
    }
    
    Rejection{
        className: "QAtomicOps"
    }
    
    Rejection{
        className: "QAtomicTraits"
    }
    
    Rejection{
        className: "QtJambiNativeID"
    }
    
    Rejection{
        className: "QFutureIterator"
    }
    
    
    Rejection{
        className: "QAudioEngineFactoryInterface"
    }
    
    Rejection{
        className: "QAudioEnginePlugin"
    }
    
    Rejection{
        className: "QHelpGlobal"
    }
    
    Rejection{
        className: "QCommandLineParser"
        functionName: "tr"
    }
    
    Rejection{
        className: "QCommandLineParser"
        functionName: "trUtf8"
    }
    
    Rejection{
        className: "QWinEventNotifier"
    }
    
    Rejection{
        className: "QModelRoleDataSpan"
    }
    
    Rejection{
        className: "QTypeRevision"
    }
    
    Rejection{
        className: "QAdoptSharedDataTag"
    }
    
    Rejection{
        className: "QAssociativeConstIterator"
    }
    
    Rejection{
        className: "QAssociativeIterator"
    }
    
    Rejection{
        className: "QBaseIterator"
    }
    
    Rejection{
        className: "QBasicUtf8StringView"
    }
    
    Rejection{
        className: "QBindingStatus"
    }
    
    Rejection{
        className: "QConstIterator"
    }
    
    Rejection{
        className: "QIterator"
    }
    
    Rejection{
        className: "QListSpecialMethodsBase"
    }
    
    Rejection{
        className: "QMetaAssociation"
    }
    
    Rejection{
        className: "QMetaContainer"
    }
    
    Rejection{
        className: "QMetaSequence"
    }
    
    Rejection{
        className: "QModelRoleData"
    }
    
    Rejection{
        className: "QMultiHash::iterator"
    }
    
    Rejection{
        className: "QMultiHash::key_iterator"
    }
    
    Rejection{
        className: "QMultiHashIterator"
    }
    
    Rejection{
        className: "QMultiMap::iterator"
    }
    
    Rejection{
        className: "QMultiMap::key_iterator"
    }
    
    Rejection{
        className: "QMultiMapIterator"
    }
    
    Rejection{
        className: "QMutableMultiHashIterator"
    }
    
    Rejection{
        className: "QMutableMultiMapIterator"
    }
    
    Rejection{
        className: "TypeInfo"
    }
    
    Rejection{
        className: "QPropertyProxyBindingData"
    }
    
    Rejection{
        className: "QObjectBindableProperty"
    }
    
    Rejection{
        className: "QObjectComputedProperty"
    }
    
    Rejection{
        className: "QPluginMetaData"
    }
    
    Rejection{
        className: "QProperty"
    }
    
    Rejection{
        className: "QPropertyAlias"
    }
    
    Rejection{
        className: "QPropertyBindingPrivatePtr"
    }
    
    Rejection{
        className: "QPropertyChangeHandler"
    }
    
    Rejection{
        className: "QPropertyNotifier"
    }
    
    Rejection{
        className: "QPropertyData"
    }
    
    Rejection{
        className: "QSequentialConstIterator"
    }
    
    Rejection{
        className: "QSequentialIterator"
    }
    
    Rejection{
        className: "QStringDecoder"
    }
    
    Rejection{
        className: "QStringEncoder"
    }
    
    Rejection{
        className: "QStringTokenizer"
    }
    
    Rejection{
        className: "QStringTokenizerBase"
    }
    
    Rejection{
        className: "QStringTokenizerBaseBase"
    }
    
    Rejection{
        className: "QTaggedIterator"
    }
    
    Rejection{
        className: "QTaggedPointer"
    }
    
    Rejection{
        className: "QVariantConstPointer"
    }
    
    Rejection{
        className: "QVariantPointer"
    }
    
    Rejection{
        className: "QVariantRef"
    }
    
    NamespaceType{
        name: "Qt"
        ExtraIncludes{
            Include{
                fileName: "QtCore/QProperty"
                location: Include.Global
                since: 6
            }
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class Qt___"
                quoteBeforeLine: "}// class"
            }
        }
    }
    
    NamespaceType{
        name: "QtPrivate"
        generate: false
    }
    
    EnumType{
        name: "PropertyFlags"
        packageName: "io.qt.internal"
        flags: "PropertyAttributes"
    }
    
    EnumType{
        name: "MethodFlags"
        packageName: "io.qt.internal"
        flags: "MethodAttributes"
        RejectEnumValue{
            name: "MethodMethod"
        }
        RejectEnumValue{
            name: "MethodTypeMask"
        }
    }
    
    EnumType{
        name: "EnumFlags"
        packageName: "io.qt.internal"
        flags: "EnumAttributes"
    }
    
    EnumType{
        name: "MetaObjectFlags"
        packageName: "io.qt.internal"
        flags: "MetaObjectAttributes"
        until: 5
    }
    
    EnumType{
        name: "MetaObjectFlag"
        packageName: "io.qt.internal"
        flags: "MetaObjectFlags"
        since: 6
    }
    
    EnumType{
        name: "MetaDataFlags"
        packageName: "io.qt.internal"
        flags: "MetaDataAttributes"
    }
    
    EnumType{
        name: "QDate::MonthNameType"
    }
    
    EnumType{
        name: "QAbstractAnimation::State"
    }
    
    EnumType{
        name: "QAbstractAnimation::DeletionPolicy"
    }
    
    EnumType{
        name: "QAbstractAnimation::Direction"
    }
    
    EnumType{
        name: "QDataStream::FloatingPointPrecision"
    }
    
    EnumType{
        name: "QDataStream::ByteOrder"
    }
    
    EnumType{
        name: "QEasingCurve::Type"
    }
    
    EnumType{
        name: "QHistoryState::HistoryType"
        until: 5
    }
    
    EnumType{
        name: "QState::ChildMode"
        until: 5
    }
    
    EnumType{
        name: "QState::RestorePolicy"
        until: 5
    }
    
    EnumType{
        name: "QStateMachine::Error"
        until: 5
    }
    
    EnumType{
        name: "QStateMachine::EventPriority"
        until: 5
    }
    
    
    EnumType{
        name: "Qt::InputMethodQuery"
        flags: "Qt::InputMethodQueries"
        RejectEnumValue{
            name: "ImMicroFocus"
        }
    }
    
    EnumType{
        name: "Qt::AnchorPoint"
    }
    
    EnumType{
        name: "Qt::CoordinateSystem"
    }
    
    EnumType{
        name: "Qt::CursorMoveStyle"
    }
    
    
    EnumType{
        name: "Qt::GestureState"
    }
    
    EnumType{
        name: "Qt::InputMethodHint"
        flags: "Qt::InputMethodHints"
    }
    
    EnumType{
        name: "Qt::NavigationMode"
    }
    
    
    EnumType{
        name: "Qt::TileRule"
    }
    
    EnumType{
        name: "Qt::TimerType"
    }
    
    EnumType{
        name: "Qt::EnterKeyType"
    }
    
    EnumType{
        name: "Qt::ChecksumType"
        since: [5, 9]
    }
    
    EnumType{
        name: "Qt::HighDpiScaleFactorRoundingPolicy"
        since: [5, 14]
    }
    
    EnumType{
        name: "Qt::TouchPointState"
        flags: "Qt::TouchPointStates"
    }
    
    EnumType{
        name: "Qt::ApplicationState"
        flags: "Qt::ApplicationStates"
    }
    
    EnumType{
        name: "Qt::FindChildOption"
        flags: "Qt::FindChildOptions"
    }
    
    EnumType{
        name: "Qt::ScreenOrientation"
        flags: "Qt::ScreenOrientations"
    }

    EnumType{
        name: "Qt::PermissionStatus"
        since: [6, 5]
    }
    
    EnumType{
        name: "QtMsgType"
        RejectEnumValue{
            name: "QtSystemMsg"
        }
    }
    
    EnumType{
        name: "QtPluginMetaDataKeys"
        packageName: "io.qt.core.internal"
        since: [6, 3]
    }
    
    EnumType{
        name: "QTextBoundaryFinder::BoundaryReason"
        flags: "QTextBoundaryFinder::BoundaryReasons"
    }
    
    EnumType{
        name: "QTextBoundaryFinder::BoundaryType"
    }
    
    EnumType{
        name: "QDataStream::Status"
    }
    
    EnumType{
        name: "QDir::Filter"
        flags: "QDir::Filters"
    }
    
    EnumType{
        name: "QEvent::Type"
        extensible: true
        RejectEnumValue{
            name: "ApplicationActivated"
        }
        RejectEnumValue{
            name: "ApplicationDeactivated"
        }
        RenameEnumValue{
            name: "DeferredDelete"
            rename: "DeferredDispose"
        }
    }
    
    EnumType{
        name: "QEventLoop::ProcessEventsFlag"
        flags: "QEventLoop::ProcessEventsFlags"
    }
    
    EnumType{
        name: "QIODevice::OpenModeFlag"
        flags: "QIODevice::OpenMode"
        until: 5
    }
    
    EnumType{
        name: "QIODeviceBase::OpenModeFlag"
        flags: "QIODeviceBase::OpenMode"
        since: 6
    }
    
    EnumType{
        name: "QLibraryInfo::LibraryLocation"
        until: 5
    }
    
    EnumType{
        name: "QLibraryInfo::LibraryPath"
        RejectEnumValue{
            name: "Qml2ImportsPath"
            since: [6, 2]
        }
        since: 6
    }
    
    EnumType{
        name: "QLocale::CurrencySymbolFormat"
    }
    
    
    EnumType{
        name: "QLocale::FormatType"
    }
    
    EnumType{
        name: "QLocale::NumberOption"
        flags: "QLocale::NumberOptions"
    }
    
    EnumType{
        name: "QLocale::MeasurementSystem"
        RejectEnumValue{
            name: "ImperialSystem"
        }
    }
    
    EnumType{
        name: "QLocale::DataSizeFormat"
        flags: "QLocale::DataSizeFormats"
        RejectEnumValue{
            name: "DataSizeTraditionalFormat"
        }
        since: [5, 10]
    }
    
    EnumType{
        name: "QLocale::LanguageCodeType"
        flags: "QLocale::LanguageCodeTypes"
        RejectEnumValue{
            name: "ISO639Alpha2"
        }
        since: [6, 3]
    }
    
    EnumType{
        name: "QUrl::AceProcessingOption"
        flags: "QUrl::AceProcessingOptions"
        since: [6, 3]
    }
    
    EnumType{
        name: "QFutureInterfaceBase::CancelMode"
        since: [6, 3]
    }
    
    EnumType{
        name: "QProcessEnvironment::Initialization"
        since: [6, 3]
    }
    
    EnumType{
        name: "QLocale::QuotationStyle"
    }
    
    
    EnumType{
        name: "QLocale::FloatingPointPrecisionOption"
        since: [5, 7]
    }
    
    EnumType{
        name: "QCommandLineOption::Flag"
        flags: "QCommandLineOption::Flags"
        since: [5, 8]
    }
    
    EnumType{
        name: "QProcess::ExitStatus"
        ppCondition: "QT_CONFIG(process)"
    }
    
    EnumType{
        name: "QProcess::ProcessChannel"
        ppCondition: "QT_CONFIG(process)"
    }
    
    EnumType{
        name: "QProcess::ProcessChannelMode"
        ppCondition: "QT_CONFIG(process)"
    }
    
    EnumType{
        name: "QProcess::ProcessError"
        ppCondition: "QT_CONFIG(process)"
    }
    
    EnumType{
        name: "QProcess::ProcessState"
        ppCondition: "QT_CONFIG(process)"
    }
    
    EnumType{
        name: "QProcess::InputChannelMode"
        ppCondition: "QT_CONFIG(process)"
    }
    
    EnumType{
        name: "QCommandLineParser::SingleDashWordOptionMode"
    }
    
    EnumType{
        name: "QCommandLineParser::OptionsAfterPositionalArgumentsMode"
    }
    
    EnumType{
        name: "QRegExp::CaretMode"
        until: 5
    }
    
    EnumType{
        name: "QRegExp::PatternSyntax"
        until: 5
    }
    
    EnumType{
        name: "QSettings::Format"
    }
    
    EnumType{
        name: "QSettings::Scope"
    }
    
    EnumType{
        name: "QSettings::Status"
    }
    
    EnumType{
        name: "QSocketNotifier::Type"
    }
    
    EnumType{
        name: "QTextCodec::ConversionFlag"
        flags: "QTextCodec::ConversionFlags"
        until: [5, 16]
    }
    
    EnumType{
        name: "QStringConverterBase::Flag"
        flags: "QStringConverterBase::Flags"
        since: 6
    }
    
    EnumType{
        name: "QTextStream::FieldAlignment"
    }
    
    EnumType{
        name: "QTextStream::NumberFlag"
        flags: "QTextStream::NumberFlags"
    }
    
    EnumType{
        name: "QTextStream::RealNumberNotation"
    }
    
    EnumType{
        name: "QTextStream::Status"
    }
    
    EnumType{
        name: "QTimeLine::CurveShape"
    }
    
    EnumType{
        name: "QTimeLine::Direction"
    }
    
    EnumType{
        name: "QTimeLine::State"
    }
    
    EnumType{
        name: "QUrl::UserInputResolutionOption"
        flags: "QUrl::UserInputResolutionOptions"
    }
    
    EnumType{
        name: "QUrl::UrlFormattingOption"
        implementing: "FormattingOption"
    }
    
    EnumType{
        name: "QUrl::ComponentFormattingOption"
        flags: "QUrl::ComponentFormattingOptions"
        implementing: "FormattingOption"
    }
    
    EnumType{
        name: "QUrl::ParsingMode"
    }
    
    EnumType{
        name: "QUuid::Variant"
    }
    
    EnumType{
        name: "QUuid::Version"
        RejectEnumValue{
            name: "Name"
        }
    }
    
    EnumType{
        name: "Qt::SizeHint"
    }
    
    EnumType{
        name: "Qt::SizeMode"
    }
    
    EnumType{
        name: "Qt::WindowFrameSection"
    }
    
    EnumType{
        name: "Qt::Axis"
    }
    
    EnumType{
        name: "Qt::ApplicationAttribute"
        RejectEnumValue{
            name: "AA_MacPluginApplication"
            since: [5, 7]
        }
    }
    
    EnumType{
        name: "Qt::ArrowType"
    }
    
    EnumType{
        name: "Qt::AspectRatioMode"
    }
    
    EnumType{
        name: "Qt::BGMode"
    }
    
    EnumType{
        name: "Qt::BrushStyle"
    }
    
    EnumType{
        name: "Qt::CaseSensitivity"
    }
    
    EnumType{
        name: "Qt::CheckState"
    }
    
    EnumType{
        name: "Qt::ClipOperation"
    }
    
    EnumType{
        name: "Qt::ConnectionType"
    }
    
    EnumType{
        name: "Qt::ContextMenuPolicy"
    }
    
    EnumType{
        name: "Qt::Corner"
    }
    
    EnumType{
        name: "Qt::DayOfWeek"
    }
    
    EnumType{
        name: "Qt::DockWidgetAreaSizes"
    }
    
    EnumType{
        name: "Qt::DropAction"
        flags: "Qt::DropActions"
    }
    
    EnumType{
        name: "Qt::FillRule"
    }
    
    EnumType{
        name: "Qt::FocusPolicy"
    }
    
    EnumType{
        name: "Qt::FocusReason"
    }
    
    EnumType{
        name: "Qt::GlobalColor"
    }
    
    EnumType{
        name: "Qt::HitTestAccuracy"
    }
    
    EnumType{
        name: "Qt::ItemFlag"
        flags: "Qt::ItemFlags"
        RejectEnumValue{
            name: "ItemIsTristate"
        }
    }
    
    EnumType{
        name: "Qt::ItemSelectionMode"
    }
    
    EnumType{
        name: "Qt::KeyboardModifier"
        flags: "Qt::KeyboardModifiers"
    }
    
    EnumType{
        name: "Qt::LayoutDirection"
    }
    
    EnumType{
        name: "Qt::MatchFlag"
        flags: "Qt::MatchFlags"
        RejectEnumValue{
            name: "MatchRegExp"
            since: 6
        }
    }
    
    EnumType{
        name: "Qt::Orientation"
        flags: "Qt::Orientations"
    }
    
    EnumType{
        name: "Qt::PenCapStyle"
    }
    
    EnumType{
        name: "Qt::PenJoinStyle"
    }
    
    EnumType{
        name: "Qt::PenStyle"
    }
    
    EnumType{
        name: "Qt::ScrollBarPolicy"
    }
    
    EnumType{
        name: "Qt::ShortcutContext"
    }
    
    EnumType{
        name: "Qt::SortOrder"
    }
    
    EnumType{
        name: "Qt::TextElideMode"
    }
    
    EnumType{
        name: "Qt::TextFlag"
    }
    
    EnumType{
        name: "Qt::TextFormat"
    }
    
    EnumType{
        name: "Qt::TextInteractionFlag"
        flags: "Qt::TextInteractionFlags"
    }
    
    EnumType{
        name: "Qt::TimeSpec"
    }
    
    EnumType{
        name: "Qt::ToolBarAreaSizes"
    }
    
    EnumType{
        name: "Qt::ToolButtonStyle"
    }
    
    EnumType{
        name: "Qt::TransformationMode"
    }
    
    EnumType{
        name: "Qt::UIEffect"
    }
    
    EnumType{
        name: "Qt::WhiteSpaceMode"
    }
    
    EnumType{
        name: "Qt::WindowModality"
    }
    
    EnumType{
        name: "Qt::GestureType"
    }
    
    EnumType{
        name: "Qt::NativeGestureType"
    }
    
    EnumType{
        name: "Qt::GestureFlag"
        flags: "Qt::GestureFlags"
    }
    
    EnumType{
        name: "Qt::MouseEventFlag"
        flags: "Qt::MouseEventFlags"
    }
    
    EnumType{
        name: "Qt::MouseEventSource"
    }
    
    EnumType{
        name: "Qt::WindowState"
        flags: "Qt::WindowStates"
    }
    
    EnumType{
        name: "Qt::WindowType"
        flags: "Qt::WindowFlags"
        RejectEnumValue{
            name: "X11BypassWindowManagerHint"
        }
        RejectEnumValue{
            name: "WindowOkButtonHint"
        }
        RejectEnumValue{
            name: "WindowCancelButtonHint"
        }
    }
    
    EnumType{
        name: "QDirIterator::IteratorFlag"
        flags: "QDirIterator::IteratorFlags"
    }
    
    EnumType{
        name: "Qt::EventPriority"
    }
    
    EnumType{
        name: "Qt::MaskMode"
    }

    EnumType{
        name: "Qt::ToolBarArea"
        flags: "Qt::ToolBarAreas"
        RejectEnumValue{
            name: "AllToolBarAreas"
        }
    }

    EnumType{
        name: "Qt::WidgetAttribute"
        RejectEnumValue{
            name: "WA_ForceAcceptDrops"
        }
        RejectEnumValue{
            name: "WA_NoBackground"
        }
        RejectEnumValue{
            name: "WA_MacMetalStyle"
        }
    }

    EnumType{
        name: "Qt::ReturnByValueConstant"
        generate: false
        since: [5, 15]
    }

    EnumType{
        name: "Qt::SplitBehaviorFlags"
        flags: "Qt::SplitBehavior"
        since: [5, 14]
    }

    EnumType{
        name: "Qt::Appearance"
        since: [6, 5]
    }
    
    EnumType{
        name: "QCryptographicHash::Algorithm"
        RejectEnumValue{
            name: "RealSha3_224"
        }
        RejectEnumValue{
            name: "RealSha3_256"
        }
        RejectEnumValue{
            name: "RealSha3_384"
        }
        RejectEnumValue{
            name: "RealSha3_512"
        }
    }
    
    EnumType{
        name: "QStandardPaths::LocateOption"
        flags: "QStandardPaths::LocateOptions"
    }
    
    EnumType{
        name: "QStandardPaths::StandardLocation"
        RejectEnumValue{
            name: "DataLocation"
        }
    }
    
    EnumType{
        name: "Qt::AlignmentFlag"
        flags: "Qt::Alignment"
        RejectEnumValue{
            name: "AlignLeading"
        }
        RejectEnumValue{
            name: "AlignTrailing"
        }
    }
    
    EnumType{
        name: "Qt::CursorShape"
        RejectEnumValue{
            name: "LastCursor"
        }
    }
    
    EnumType{
        name: "Qt::DateFormat"
        RejectEnumValue{
            name: "LocalDate"
        }
    }
    
    EnumType{
        name: "Qt::ItemSelectionOperation"
    }
    
    EnumType{
        name: "Qt::TabFocusBehavior"
    }
    
    EnumType{
        name: "Qt::Edge"
        flags: "Qt::Edges"
    }
    
    EnumType{
        name: "Qt::ScrollPhase"
    }
    
    EnumType{
        name: "Qt::ItemDataRole"
        forceInteger: true
        RejectEnumValue{
            name: "BackgroundColorRole"
        }
        RejectEnumValue{
            name: "TextColorRole"
        }
    }
    
    EnumType{
        name: "Qt::MouseButton"
        flags: "Qt::MouseButtons"
        RejectEnumValue{
            name: "MiddleButton"
            until: 5
        }
        RejectEnumValue{
            name: "XButton1"
        }
        RejectEnumValue{
            name: "BackButton"
        }
        RejectEnumValue{
            name: "ForwardButton"
        }
        RejectEnumValue{
            name: "XButton2"
        }
        RejectEnumValue{
            name: "TaskButton"
        }
        RejectEnumValue{
            name: "MaxMouseButton"
        }
    }
    
    EnumType{
        name: "QDataStream::Version"
        RejectEnumValue{
            name: "Qt_4_1"
        }
        RejectEnumValue{
            name: "Qt_4_7"
        }
        RejectEnumValue{
            name: "Qt_4_8"
        }
        RejectEnumValue{
            name: "Qt_4_9"
        }
        RejectEnumValue{
            name: "Qt_5_3"
        }
        RejectEnumValue{
            name: "Qt_5_5"
        }
        RejectEnumValue{
            name: "Qt_5_7"
            since: [5, 7]
        }
        RejectEnumValue{
            name: "Qt_5_8"
            since: [5, 8]
        }
        RejectEnumValue{
            name: "Qt_5_9"
            since: [5, 9]
        }
        RejectEnumValue{
            name: "Qt_5_10"
            since: [5, 10]
        }
        RejectEnumValue{
            name: "Qt_5_11"
            since: [5, 11]
        }
        RejectEnumValue{
            name: "Qt_5_14"
            since: [5, 14]
        }
        RejectEnumValue{
            name: "Qt_5_15"
            since: [5, 15]
        }
        RejectEnumValue{
            name: "Qt_6_1"
            since: [6, 1]
        }
        RejectEnumValue{
            name: "Qt_6_2"
            since: [6, 2]
        }
        RejectEnumValue{
            name: "Qt_6_3"
            since: [6, 3]
        }
        RejectEnumValue{
            name: "Qt_6_4"
            since: [6, 4]
        }
        RejectEnumValue{
            name: "Qt_6_5"
            since: [6, 5]
        }
        RejectEnumValue{
            name: "Qt_DefaultCompiledVersion"
        }
    }
    
    EnumType{
        name: "QDir::SortFlag"
        flags: "QDir::SortFlags"
        RejectEnumValue{
            name: "Unsorted"
        }
    }
    
    EnumType{
        name: "Qt::DockWidgetArea"
        flags: "Qt::DockWidgetAreas"
        RejectEnumValue{
            name: "AllDockWidgetAreas"
        }
    }
    
    EnumType{
        name: "Qt::ImageConversionFlag"
        flags: "Qt::ImageConversionFlags"
        RejectEnumValue{
            name: "AutoDither"
        }
        RejectEnumValue{
            name: "ColorOnly"
        }
        RejectEnumValue{
            name: "DiffuseDither"
        }
        RejectEnumValue{
            name: "NoAlpha"
        }
        RejectEnumValue{
            name: "ThresholdAlphaDither"
        }
    }
    
    EnumType{
        name: "Qt::Key"
        RejectEnumValue{
            name: "Key_Any"
        }
    }
    
    EnumType{
        name: "QLocale::Language"
        RejectEnumValue{
            name: "Afan"
        }
        RejectEnumValue{
            name: "Bengali"
            since: 6
        }
        RejectEnumValue{
            name: "Bhutani"
        }
        RejectEnumValue{
            name: "Byelorussian"
        }
        RejectEnumValue{
            name: "Cambodian"
        }
        RejectEnumValue{
            name: "CentralMoroccoTamazight"
            since: 6
        }
        RejectEnumValue{
            name: "Chewa"
        }
        RejectEnumValue{
            name: "Frisian"
        }
        RejectEnumValue{
            name: "Greenlandic"
            since: 6
        }
        RejectEnumValue{
            name: "Inupiak"
            since: 6
        }
        RejectEnumValue{
            name: "Kirghiz"
            since: 6
        }
        RejectEnumValue{
            name: "Kwanyama"
            since: 6
        }
        RejectEnumValue{
            name: "Navaho"
            since: 6
        }
        RejectEnumValue{
            name: "Oriya"
            since: 6
        }
        RejectEnumValue{
            name: "Uighur"
            since: 6
        }
        RejectEnumValue{
            name: "Walamo"
            since: 6
        }
        RejectEnumValue{
            name: "Kurundi"
        }
        RejectEnumValue{
            name: "Moldavian"
        }
        RejectEnumValue{
            name: "Norwegian"
        }
        RejectEnumValue{
            name: "RhaetoRomance"
        }
        RejectEnumValue{
            name: "SerboCroatian"
        }
        RejectEnumValue{
            name: "Tagalog"
        }
        RejectEnumValue{
            name: "Twi"
        }
        RejectEnumValue{
            name: "Uigur"
        }
        RejectEnumValue{
            name: "LastLanguage"
        }
    }
    
    EnumType{
        name: "QLocale::Country"
        RejectEnumValue{
            name: "DemocraticRepublicOfCongo"
        }
        RejectEnumValue{
            name: "PeoplesRepublicOfCongo"
        }
        RejectEnumValue{
            name: "DemocraticRepublicOfKorea"
        }
        RejectEnumValue{
            name: "RepublicOfKorea"
        }
        RejectEnumValue{
            name: "RussianFederation"
        }
        RejectEnumValue{
            name: "SyrianArabRepublic"
        }
        RejectEnumValue{
            name: "Tokelau"
            since: [5, 7]
        }
        RejectEnumValue{
            name: "Tuvalu"
            since: [5, 7]
        }
        RejectEnumValue{
            name: "LastCountry"
        }
        RejectEnumValue{
            name: "LatinAmericaAndTheCaribbean"
        }
        RejectEnumValue{
            name: "Bonaire"
            since: 6
        }
        RejectEnumValue{
            name: "BosniaAndHerzegowina"
            since: 6
        }
        RejectEnumValue{
            name: "CuraSao"
            since: 6
        }
        RejectEnumValue{
            name: "CzechRepublic"
            since: 6
        }
        RejectEnumValue{
            name: "EastTimor"
            since: 6
        }
        RejectEnumValue{
            name: "Macau"
            since: 6
        }
        RejectEnumValue{
            name: "SaintVincentAndTheGrenadines"
            since: 6
        }
        RejectEnumValue{
            name: "SouthGeorgiaAndTheSouthSandwichIslands"
            since: 6
        }
        RejectEnumValue{
            name: "SvalbardAndJanMayenIslands"
            since: 6
        }
        RejectEnumValue{
            name: "UnitedStatesMinorOutlyingIslands"
            since: 6
        }
        RejectEnumValue{
            name: "VaticanCityState"
            since: 6
        }
        RejectEnumValue{
            name: "WallisAndFutunaIslands"
            since: 6
        }
        RejectEnumValue{
            name: "Swaziland"
            since: 6
        }
        RejectEnumValue{
            name: "AnyTerritory"
            since: [6, 2]
        }
        RejectEnumValue{
            name: "NauruTerritory"
            since: [6, 2]
        }
        RejectEnumValue{
            name: "TokelauTerritory"
            since: [6, 2]
        }
        RejectEnumValue{
            name: "TuvaluTerritory"
            since: [6, 2]
        }
        RejectEnumValue{
            name: "LastTerritory"
            since: [6, 2]
        }
    }
    
    EnumType{
        name: "QLocale::Script"
        RejectEnumValue{
            name: "SimplifiedChineseScript"
        }
        RejectEnumValue{
            name: "TraditionalChineseScript"
        }
        RejectEnumValue{
            name: "LastScript"
        }
        RejectEnumValue{
            name: "BengaliScript"
            since: 6
        }
        RejectEnumValue{
            name: "MendeKikakuiScript"
            since: 6
        }
        RejectEnumValue{
            name: "OriyaScript"
            since: 6
        }
    }
    
    EnumType{
        name: "QElapsedTimer::ClockType"
    }
    
    EnumType{
        name: "QXmlStreamReader::Error"
    }
    
    EnumType{
        name: "QXmlStreamReader::TokenType"
    }
    
    EnumType{
        name: "QXmlStreamReader::ReadElementTextBehaviour"
    }
    
    EnumType{
        name: "QFileDevice::FileError"
    }
    
    EnumType{
        name: "QFileDevice::FileTime"
        since: [5, 10]
    }
    
    EnumType{
        name: "QFileDevice::FileHandleFlag"
        flags: "QFileDevice::FileHandleFlags"
    }
    
    EnumType{
        name: "QFileDevice::Permission"
        flags: "QFileDevice::Permissions"
    }
    
    EnumType{
        name: "QFileDevice::MemoryMapFlags"
        until: 5
    }
    
    EnumType{
        name: "QFileDevice::MemoryMapFlag"
        flags: "QFileDevice::MemoryMapFlags"
        since: 6
    }
    
    EnumType{
        name: "QJsonDocument::DataValidation"
        until: 5
    }
    
    EnumType{
        name: "QJsonDocument::JsonFormat"
    }
    
    EnumType{
        name: "QJsonParseError::ParseError"
    }
    
    EnumType{
        name: "QJsonValue::Type"
    }
    
    EnumType{
        name: "QMimeDatabase::MatchMode"
    }
    
    EnumType{
        name: "QRegularExpression::MatchOption"
        flags: "QRegularExpression::MatchOptions"
        RejectEnumValue{
            name: "AnchoredMatchOption"
            since: 6
        }
    }
    
    EnumType{
        name: "QRegularExpression::MatchType"
    }
    
    EnumType{
        name: "QRegularExpression::PatternOption"
        flags: "QRegularExpression::PatternOptions"
    }
    
    EnumType{
        name: "QAbstractItemModel::LayoutChangeHint"
    }
    
    EnumType{
        name: "QAbstractItemModel::CheckIndexOption"
        flags: "QAbstractItemModel::CheckIndexOptions"
    }
    
    EnumType{
        name: "QUuid::StringFormat"
    }
    
    EnumType{
        name: "QLineF::IntersectType"
        until: 5
    }
    
    EnumType{
        name: "QLineF::IntersectionType"
        since: 6
    }
    
    EnumType{
        name: "QByteArray::Base64Option"
        flags: "QByteArray::Base64Options"
        RejectEnumValue{
            name: "KeepTrailingEquals"
        }
        RejectEnumValue{
            name: "IgnoreBase64DecodingErrors"
        }
    }
    
    EnumType{
        name: "QByteArray::Base64DecodingStatus"
    }
    
    EnumType{
        name: "QTimeZone::TimeType"
    }
    
    EnumType{
        name: "QTimeZone::NameType"
    }
    
    EnumType{
        name: "QSysInfo::Endian"
        RejectEnumValue{
            name: "ByteOrder"
        }
    }
    
    NamespaceType{
        name: "QSysInfo"
        InjectCode{
            target: CodeClass.Java
            Text{content: "private native static int byteOrder();\n"+
                          "private native static int wordSize();\n"+
                          "\n"+
                          "public static final Endian ByteOrder = Endian.resolve(byteOrder());\n"+
                          "\n"+
                          "public static final int WordSize = wordSize();"}
        }
        InjectCode{
            target: CodeClass.Native
            Text{content: "extern \"C\" Q_DECL_EXPORT jint JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QSysInfo_byteOrder__)\n"+
                          "(JNIEnv *, jclass)\n"+
                          "{\n"+
                          "    return jint(QSysInfo::ByteOrder);\n"+
                          "}\n"+
                          "extern \"C\" Q_DECL_EXPORT jint JNICALL QTJAMBI_FUNCTION_PREFIX(Java_io_qt_core_QSysInfo_wordSize__)\n"+
                          "(JNIEnv *, jclass)\n"+
                          "{\n"+
                          "    return jint(QSysInfo::WordSize);\n"+
                          "}"}
        }
        ModifyField{
            name: "ByteOrder"
            read: false
            write: false
        }
    }
    
    ValueType{
        name: "QVectorSpecialMethods"
        generate: false
    }
    
    ValueType{
        name: "QLine"
    }
    
    ValueType{
        name: "QLineF"
        ModifyFunction{
            signature: "intersect(QLineF,QPointF*)const"
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "io.qt.core.QPointF"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QPointF* %out = qtjambi_cast<QPointF*>(%env, %in);"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "intersects(QLineF,QPointF*)const"
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "io.qt.core.QPointF"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QPointF* %out = qtjambi_cast<QPointF*>(%env, %in);"}
                }
            }
            since: [5, 14]
        }
    }
    
    ValueType{
        name: "QElapsedTimer"
    }
    
    ValueType{
        name: "QProcessEnvironment"
        ModifyFunction{
            signature: "operator=(const QProcessEnvironment&)"
            remove: RemoveFlag.All
        }
    }
    
    ObjectType{
        name: "QBasicTimer"
        ModifyFunction{
            signature: "operator=(const QBasicTimer&)"
            remove: RemoveFlag.All
        }
    }
    
    ValueType{
        name: "QByteArrayMatcher"
        ModifyFunction{
            signature: "operator=(QByteArrayMatcher)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "QByteArrayMatcher(const char*,int)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "QByteArrayMatcher(const char*,qsizetype)"
            remove: RemoveFlag.All
            ModifyArgument{
                index: 1
                NoNullPointer{
                }
                ArrayType{
                    lengthParameter: 2
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "indexIn(const char*,int,int)const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "indexIn(const char*,qsizetype,qsizetype)const"
            remove: RemoveFlag.All
            since: 6
        }
    }
    
    ValueType{
        name: "QDate"
        ModifyFunction{
            signature: "toString(QStringView) const"
            remove: RemoveFlag.All
            since: [5, 10]
            until: 5
        }
        ModifyFunction{
            signature: "toString(QStringView,QCalendar)const"
            remove: RemoveFlag.All
            since: [5, 14]
        }
        ModifyFunction{
            signature: "fromString(QString,Qt::DateFormat)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "fromString(QStringView,QStringView,QCalendar)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "fromString(QString,QString,QCalendar)"
            remove: RemoveFlag.All
            since: 6
        }
        ExtraIncludes{
            Include{
                fileName: "utils_p.h"
                location: Include.Local
            }
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QDate___"
                quoteBeforeLine: "}// class"
            }
        }
        ModifyFunction{
            signature: "weekNumber(int*)const"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "io.qt.core.QDate$Week"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = Java::QtCore::QDate$Week::newInstance(%env, %in, yearNumber);"}
                }
            }
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "int yearNumber(0);\n"+
                                  "int* %out = &yearNumber;"}
                }
            }
        }
        ModifyFunction{
            signature: "getDate(int*,int*,int*)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "getDate(int*,int*,int*) const"
            remove: RemoveFlag.All
            since: [5, 9]
        }
    }
    
    ValueType{
        name: "QDateTime"
        ModifyFunction{
            signature: "operator=(QDateTime)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "toString(QStringView) const"
            remove: RemoveFlag.All
            since: [5, 10]
            until: 5
        }
        ModifyFunction{
            signature: "toString(QStringView,QCalendar) const"
            remove: RemoveFlag.All
            since: [5, 15]
        }
        ModifyFunction{
            signature: "fromString(const QString &, Qt::DateFormat)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "fromString(const QString &, const QString &, QCalendar)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "fromString(QStringView, QStringView, QCalendar)"
            remove: RemoveFlag.All
            since: 6
        }
    }
    
    ValueType{
        name: "QDir"
        ModifyFunction{
            signature: "QDir(QString,QString,QFlags<QDir::SortFlag>,QFlags<QDir::Filter>)"
            ModifyArgument{
                index: 3
                ReplaceDefaultExpression{
                    expression: "SortFlag.Name, SortFlag.IgnoreCase"
                }
            }
        }
        ModifyFunction{
            signature: "operator=(QDir)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator=(QString)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "addResourceSearchPath(QString)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "operator[](int)const"
            rename: "at"
            until: [6,4]
        }
        ModifyFunction{
            signature: "operator[](qsizetype)const"
            rename: "at"
            since: [6,5]
        }
        InjectCode{
            target: CodeClass.Java
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QDir__"
                quoteBeforeLine: "}// class"
            }
        }
    }
    
    ValueType{
        name: "QPoint"
        ModifyFunction{
            signature: "operator-()"
            rename: "unaryMinus"
            since: 6
        }
        ModifyFunction{
            signature: "operator+()"
            rename: "unaryPlus"
            since: 6
        }
        ModifyFunction{
            signature: "operator-(QPoint)"
            rename: "minus"
            since: 6
        }
        ModifyFunction{
            signature: "operator+(QPoint)"
            rename: "plus"
            since: 6
        }
        ModifyFunction{
            signature: "operator*(int)"
            rename: "times"
            since: 6
        }
        ModifyFunction{
            signature: "operator*(float)"
            rename: "times"
            since: 6
        }
        ModifyFunction{
            signature: "operator*(double)"
            rename: "times"
            since: 6
        }
        ModifyFunction{
            signature: "operator/(qreal)"
            rename: "div"
            since: 6
        }
        ModifyFunction{
            signature: "operator*=(int)"
            rename: "multiply"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QPoint"
                }
            }
        }
        ModifyFunction{
            signature: "operator*=(double)"
            rename: "multiply"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QPoint"
                }
            }
        }
        ModifyFunction{
            signature: "operator*=(float)"
            rename: "multiply"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QPoint"
                }
            }
        }
        ModifyFunction{
            signature: "operator/=(qreal)"
            rename: "divide"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QPoint"
                }
            }
        }
        ModifyFunction{
            signature: "operator+=(QPoint)"
            rename: "add"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QPoint"
                }
            }
        }
        ModifyFunction{
            signature: "operator-=(QPoint)"
            rename: "subtract"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QPoint"
                }
            }
        }
        ModifyFunction{
            signature: "rx()"
            Remove{
            }
        }
        ModifyFunction{
            signature: "ry()"
            Remove{
            }
        }
    }
    
    ValueType{
        name: "QPointF"
        ModifyFunction{
            signature: "operator-()"
            rename: "unaryMinus"
            since: 6
        }
        ModifyFunction{
            signature: "operator+()"
            rename: "unaryPlus"
            since: 6
        }
        ModifyFunction{
            signature: "operator-(QPointF)"
            rename: "minus"
            since: 6
        }
        ModifyFunction{
            signature: "operator+(QPointF)"
            rename: "plus"
            since: 6
        }
        ModifyFunction{
            signature: "operator*(qreal)"
            rename: "times"
            since: 6
        }
        ModifyFunction{
            signature: "operator/(qreal)"
            rename: "div"
            since: 6
        }
        ModifyFunction{
            signature: "operator*=(qreal)"
            rename: "multiply"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QPointF"
                }
            }
        }
        ModifyFunction{
            signature: "operator/=(qreal)"
            rename: "divide"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QPointF"
                }
            }
        }
        ModifyFunction{
            signature: "operator+=(QPointF)"
            rename: "add"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QPointF"
                }
            }
        }
        ModifyFunction{
            signature: "operator-=(QPointF)"
            rename: "subtract"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QPointF"
                }
            }
        }
        ModifyFunction{
            signature: "rx()"
            Remove{
            }
        }
        ModifyFunction{
            signature: "ry()"
            Remove{
            }
        }
        InjectCode{
            target: CodeClass.Native
            position: Position.Beginning
            since: [6, 2]
            Text{content: "namespace QtJambiPrivate {\n"+
                          "template<>\n"+
                          "struct RegistryHelper<QPointF, false>{\n"+
                          "    static void registerHashFunction(){ RegistryAPI::registerHashFunction(typeid(QPointF), [](const void* ptr, hash_type seed)->hash_type{ return !ptr ? 0 : qHash(*reinterpret_cast<const QPointF*>(ptr), QHashDummyValue(), seed); }); }\n"+
                          "};\n"+
                          "}"}
        }
    }
    
    ValueType{
        name: "QRect"
        ModifyFunction{
            signature: "getCoords(int*,int*,int*,int*)const"
            Remove{
            }
        }
        ModifyFunction{
            signature: "getRect(int*,int*,int*,int*)const"
            Remove{
            }
        }
        ModifyFunction{
            signature: "operator&=(QRect)"
            Remove{
            }
        }
        ModifyFunction{
            signature: "operator|=(QRect)"
            Remove{
            }
        }
        ModifyFunction{
            signature: "operator&(QRect)const"
            Remove{
            }
        }
        ModifyFunction{
            signature: "operator|(QRect)const"
            Remove{
            }
        }
        ModifyFunction{
            signature: "operator-=(const QMargins &)"
            rename: "subtract"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QRect"
                }
            }
        }
        ModifyFunction{
            signature: "operator+=(const QMargins &)"
            rename: "add"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QRect"
                }
            }
        }
    }
    
    ValueType{
        name: "QRectF"
        ModifyFunction{
            signature: "getCoords(qreal*,qreal*,qreal*,qreal*)const"
            Remove{
            }
        }
        ModifyFunction{
            signature: "getRect(qreal*,qreal*,qreal*,qreal*)const"
            Remove{
            }
        }
        ModifyFunction{
            signature: "operator&=(QRectF)"
            Remove{
            }
        }
        ModifyFunction{
            signature: "operator|=(QRectF)"
            Remove{
            }
        }
        ModifyFunction{
            signature: "operator&(QRectF)const"
            Remove{
            }
        }
        ModifyFunction{
            signature: "operator|(QRectF)const"
            Remove{
            }
        }
        ModifyFunction{
            signature: "operator-=(const QMarginsF &)"
            rename: "subtract"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QRectF"
                }
            }
        }
        ModifyFunction{
            signature: "operator+=(const QMarginsF &)"
            rename: "add"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QRectF"
                }
            }
        }
    }
    
    ValueType{
        name: "QSize"
        ModifyFunction{
            signature: "operator-(QSize)"
            rename: "minus"
            since: 6
        }
        ModifyFunction{
            signature: "operator+(QSize)"
            rename: "plus"
            since: 6
        }
        ModifyFunction{
            signature: "operator/(qreal)"
            rename: "div"
            since: 6
        }
        ModifyFunction{
            signature: "operator*(qreal)"
            rename: "times"
            since: 6
        }
        ModifyFunction{
            signature: "operator*=(qreal)"
            rename: "multiply"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QSize"
                }
            }
        }
        ModifyFunction{
            signature: "operator/=(qreal)"
            rename: "divide"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QSize"
                }
            }
        }
        ModifyFunction{
            signature: "operator+=(QSize)"
            rename: "add"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QSize"
                }
            }
        }
        ModifyFunction{
            signature: "operator-=(QSize)"
            rename: "subtract"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QSize"
                }
            }
        }
        ModifyFunction{
            signature: "rheight()"
            Remove{
            }
        }
        ModifyFunction{
            signature: "rwidth()"
            Remove{
            }
        }
    }
    
    ValueType{
        name: "QSizeF"
        ModifyFunction{
            signature: "operator-(QSizeF)"
            rename: "minus"
            since: 6
        }
        ModifyFunction{
            signature: "operator+(QSizeF)"
            rename: "plus"
            since: 6
        }
        ModifyFunction{
            signature: "operator/(qreal)"
            rename: "div"
            since: 6
        }
        ModifyFunction{
            signature: "operator*(qreal)"
            rename: "times"
            since: 6
        }
        ModifyFunction{
            signature: "operator*=(qreal)"
            rename: "multiply"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QSizeF"
                }
            }
        }
        ModifyFunction{
            signature: "operator/=(qreal)"
            rename: "divide"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QSizeF"
                }
            }
        }
        ModifyFunction{
            signature: "operator+=(QSizeF)"
            rename: "add"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QSizeF"
                }
            }
        }
        ModifyFunction{
            signature: "operator-=(QSizeF)"
            rename: "subtract"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QSizeF"
                }
            }
        }
        ModifyFunction{
            signature: "rheight()"
            Remove{
            }
        }
        ModifyFunction{
            signature: "rwidth()"
            Remove{
            }
        }
    }
    
    ValueType{
        name: "QStringMatcher"
        ModifyFunction{
            signature: "operator=(QStringMatcher)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "QStringMatcher(const QChar*,int,Qt::CaseSensitivity)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "QStringMatcher(const QChar*,qsizetype,Qt::CaseSensitivity)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "indexIn(const QChar*,int,int)const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "indexIn(const QChar*,qsizetype,qsizetype)const"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "QStringMatcher(QStringView,Qt::CaseSensitivity)"
            remove: RemoveFlag.All
            since: [5, 14]
        }
        ModifyFunction{
            signature: "indexIn(QStringView,qsizetype)const"
            remove: RemoveFlag.All
            since: [5, 14]
        }
    }
    
    ValueType{
        name: "QTime"
        ModifyFunction{
            signature: "toString(QStringView) const"
            remove: RemoveFlag.All
            since: [5, 10]
        }
        ModifyFunction{
            signature: "fromString(QStringView,QStringView)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "fromString(QString,Qt::DateFormat)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "fromString(QString,QString)"
            remove: RemoveFlag.All
            since: 6
        }
    }
    
    Rejection{
        className: "QMetaMethod"
        functionName: "invoke"
    }
    
    Rejection{
        className: "QMetaMethod"
        functionName: "invokeOnGadget"
    }
    
    Rejection{
        className: "QMetaMethod"
        functionName: "getParameterTypes"
    }
    
    ValueType{
        name: "QMetaMethod"
        ExtraIncludes{
            Include{
                fileName: "QtJambi/CoreAPI"
                location: Include.Global
            }
        }

        ModifyFunction{
            signature: "QMetaMethod()"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "methodSignature()const"
            rename: "cppMethodSignature"
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QMetaMethod___"
                quoteBeforeLine: "}// class"
            }
        }
        ModifyFunction{
            signature: "typeName()const"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        ModifyFunction{
            signature: "tag()const"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        ModifyFunction{
            signature: "name()const"
            InjectCode{
                target: CodeClass.Native
                Text{content: "bool solved = false;\n"+
                              "if(const QHash<int,const char*>* _renamedMethods = CoreAPI::renamedMethods(__qt_this->enclosingMetaObject())){\n"+
                              "    if(const char* newName = (*_renamedMethods)[__qt_this->methodIndex()]){\n"+
                              "        __java_return_value = qtjambi_cast<jobject>(__jni_env, QByteArray(newName));\n"+
                              "        solved = true;\n"+
                              "    }\n"+
                              "}\n"+
                              "if(!solved){"}
            }
            ModifyArgument{
                index: 0
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "    %in.detach();\n"+
                                  "    %out = qtjambi_cast<jobject>(%env, %in);\n"+
                                  "}"}
                }
            }
        }
    }
    
    Rejection{
        className: "QMetaProperty"
        functionName: "resetOnGadget"
    }
    
    Rejection{
        className: "QMetaProperty"
        functionName: "readOnGadget"
    }
    
    Rejection{
        className: "QMetaProperty"
        functionName: "writeOnGadget"
    }
    
    ValueType{
        name: "QMetaProperty"
        ModifyFunction{
            signature: "QMetaProperty()"
            remove: RemoveFlag.All
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QMetaProperty___"
                quoteBeforeLine: "}// class"
            }
        }
        ModifyFunction{
            signature: "name()const"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        ModifyFunction{
            signature: "typeName()const"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
    }
    
    ValueType{
        name: "QMetaEnum"
        ModifyFunction{
            signature: "QMetaEnum()"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "fromType<T>()"
            remove: RemoveFlag.All
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QMetaEnum___"
                quoteBeforeLine: "}// class"
            }
        }
        ModifyFunction{
            signature: "enumName()const"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        ModifyFunction{
            signature: "name()const"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        ModifyFunction{
            signature: "scope()const"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        ModifyFunction{
            signature: "key(int)const"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        ModifyFunction{
            signature: "valueToKey(int)const"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        ModifyFunction{
            signature: "keyToValue(const char *, bool *)const"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.lang.Integer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = ok ? qtjambi_cast<jobject>(%env, %in) : nullptr;"}
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "bool ok(false);\n"+
                                  "bool* %out = &ok;"}
                }
            }
        }
        ModifyFunction{
            signature: "keysToValue(const char *, bool *)const"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.lang.Integer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = ok ? qtjambi_cast<jobject>(%env, %in) : nullptr;"}
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "bool ok(false);\n"+
                                  "bool* %out = &ok;"}
                }
            }
        }
    }
    
    EnumType{
        name: "QMetaMethod::MethodType"
    }
    
    EnumType{
        name: "QMetaMethod::Attributes"
    }
    
    EnumType{
        name: "QMetaMethod::Access"
    }

    ValueType{
        name: "QModelIndex"
        ModifyFunction{
            signature: "internalPointer() const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "constInternalPointer() const"
            remove: RemoveFlag.All
        }
    }
    
    ValueType{
        name: "QPersistentModelIndex"
        threadAffinity: "model()"
        ModifyFunction{
            signature: "operator=(QPersistentModelIndex)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator=(QModelIndex)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "internalPointer()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "constInternalPointer()const"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "qHashEquals(QPersistentModelIndex)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "operator const QModelIndex&() const"
            rename: "toIndex"
            until: 5
        }
        ModifyFunction{
            signature: "operator QModelIndex() const"
            rename: "toIndex"
            since: 6
        }
    }
    
    ValueType{
        name: "QUuid"
        ModifyFunction{
            signature: "QUuid(const char*)"
            remove: RemoveFlag.All
            until: [6, 2]
        }
        ModifyFunction{
            signature: "fromString(QLatin1String)"
            remove: RemoveFlag.All
            since: [5, 10]
            until: [6, 2]
        }
        ModifyFunction{
            signature: "operator>>(QDataStream &,QUuid &)"
            access: Modification.NonFinal
        }
        ModifyFunction{
            signature: "operator<<(QDataStream &,QUuid)"
            access: Modification.NonFinal
        }
        ModifyFunction{
            signature: "operator>=(const QUuid&,const QUuid&)"
            remove: RemoveFlag.All
        }
        InjectCode{
            since: [6, 3]
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QUuid_63__"
                quoteBeforeLine: "}// class"
            }
        }
    }
    
    ValueType{
        name: "QLocale"
        ModifyFunction{
            signature: "toDouble(const QStringRef &, bool *) const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "toDouble(QStringView, bool *) const"
            remove: RemoveFlag.All
            since: [5, 10]
        }
        ModifyFunction{
            signature: "toFloat(const QStringRef &, bool *) const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "toFloat(QStringView, bool *) const"
            remove: RemoveFlag.All
            since: [5, 10]
        }
        ModifyFunction{
            signature: "toInt(const QStringRef &, bool *) const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "toInt(QStringView, bool *) const"
            remove: RemoveFlag.All
            since: [5, 10]
        }
        ModifyFunction{
            signature: "toUInt(const QStringRef &, bool *) const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "toUInt(QString,bool*)const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "toUInt(QStringView,bool*)const"
            remove: RemoveFlag.All
            since: [5, 10]
        }
        ModifyFunction{
            signature: "toLongLong(const QStringRef &, bool *) const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "toLongLong(QStringView, bool *) const"
            remove: RemoveFlag.All
            since: [5, 10]
        }
        ModifyFunction{
            signature: "toLong(QStringView, bool *) const"
            remove: RemoveFlag.All
            since: [5, 12]
        }
        ModifyFunction{
            signature: "toLong(const QString &, bool *) const"
            remove: RemoveFlag.All
            since: [5, 12]
        }
        ModifyFunction{
            signature: "toLong(const QStringRef &, bool *) const"
            remove: RemoveFlag.All
            since: [5, 12]
            until: 5
        }
        ModifyFunction{
            signature: "toULongLong(const QStringRef &, bool *) const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "toULongLong(QString,bool*)const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "toULongLong(QStringView,bool*)const"
            remove: RemoveFlag.All
            since: [5, 10]
        }
        ModifyFunction{
            signature: "toShort(const QStringRef &, bool *) const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "toShort(QStringView, bool *) const"
            remove: RemoveFlag.All
            since: [5, 10]
        }
        ModifyFunction{
            signature: "toUShort(const QStringRef &, bool *) const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "toUShort(QStringView, bool *) const"
            remove: RemoveFlag.All
            since: [5, 10]
        }
        ModifyFunction{
            signature: "toUShort(QString, bool *) const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "toString(unsigned long long) const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "toString(unsigned long) const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "toString(long) const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "toString(unsigned short) const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "toString(unsigned int) const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "toULong(const QStringRef &, bool *) const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "toULong(QString,bool*)const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "toULong(QStringView,bool*)const"
            remove: RemoveFlag.All
            since: [5, 10]
        }
        ModifyFunction{
            signature: "operator=(QLocale)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "toCurrencyString(unsigned short,const QString&)const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "toCurrencyString(unsigned int,const QString&)const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "toCurrencyString(unsigned long long,const QString&)const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "quoteString(const QStringRef&,QLocale::QuotationStyle)const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "quoteString(QStringView, QLocale::QuotationStyle) const"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "toString(const QDate &, QString) const"
            remove: RemoveFlag.All
            since: [5, 10]
        }
        ModifyFunction{
            signature: "toString(const QTime &, QString) const"
            remove: RemoveFlag.All
            since: [5, 10]
        }
        ModifyFunction{
            signature: "toString(const QDateTime &, QString) const"
            remove: RemoveFlag.All
            since: [5, 10]
        }
        ModifyFunction{
            signature: "formattedDataSize(long long, int, QFlags<QLocale::DataSizeFormat>)"
            remove: RemoveFlag.All
            since: [5, 12]
            until: 5
        }
        ModifyFunction{
            signature: "QLocale(QStringView)"
            remove: RemoveFlag.All
            since: [6, 3]
        }
        ExtraIncludes{
            Include{
                fileName: "QtJambi/JavaAPI"
                location: Include.Global
            }
        }
        ModifyFunction{
            signature: "toDouble(QString,bool*) const"
            throwing: "NumberFormatException"
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "bool ok(false);\n"+
                                  "bool* %out = &ok;"}
                }
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.End
                Text{content: "if(!ok)\n"+
                              "    Java::Runtime::NumberFormatException::throwNew(%env, \"Unable to parse number.\" QTJAMBI_STACKTRACEINFO );"}
            }
        }
        ModifyFunction{
            signature: "toFloat(QString,bool*) const"
            throwing: "NumberFormatException"
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "bool ok(false);\n"+
                                  "bool* %out = &ok;"}
                }
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.End
                Text{content: "if(!ok)\n"+
                              "    Java::Runtime::NumberFormatException::throwNew(%env, \"Unable to parse number.\" QTJAMBI_STACKTRACEINFO );"}
            }
        }
        ModifyFunction{
            signature: "toInt(QString,bool*) const"
            throwing: "NumberFormatException"
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "bool ok(false);\n"+
                                  "bool* %out = &ok;"}
                }
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.End
                Text{content: "if(!ok)\n"+
                              "    Java::Runtime::NumberFormatException::throwNew(%env, \"Unable to parse number.\" QTJAMBI_STACKTRACEINFO );"}
            }
        }
        ModifyFunction{
            signature: "toLongLong(QString,bool*) const"
            rename: "toLong"
            throwing: "NumberFormatException"
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "bool ok(false);\n"+
                                  "bool* %out = &ok;"}
                }
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.End
                Text{content: "if(!ok)\n"+
                              "    Java::Runtime::NumberFormatException::throwNew(%env, \"Unable to parse number.\" QTJAMBI_STACKTRACEINFO );"}
            }
        }
        ModifyFunction{
            signature: "toShort(QString,bool*) const"
            throwing: "NumberFormatException"
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "bool ok(false);\n"+
                                  "bool* %out = &ok;"}
                }
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.End
                Text{content: "if(!ok)\n"+
                              "    Java::Runtime::NumberFormatException::throwNew(%env, \"Unable to parse number.\" QTJAMBI_STACKTRACEINFO );"}
            }
        }
    }
    
    ValueType{
        name: "QBitArray"
        ModifyFunction{
            signature: "operator[](int)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "operator[](int)const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "operator[](uint)const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "operator[](uint)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "operator[](qsizetype)const"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "operator[](qsizetype)"
            remove: RemoveFlag.All
            since: 6
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QBitArray___"
                quoteBeforeLine: "}// class"
            }
        }
        ExtraIncludes{
            Include{
                fileName: "QtJambi/JavaAPI"
                location: Include.Global
            }
        }
        ModifyFunction{
            signature: "operator&=(QBitArray)"
            rename: "and"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QBitArray"
                }
            }
        }
        ModifyFunction{
            signature: "operator=(QBitArray)"
            rename: "set"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QBitArray"
                }
            }
        }
        ModifyFunction{
            signature: "operator^=(QBitArray)"
            rename: "xor"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QBitArray"
                }
            }
        }
        ModifyFunction{
            signature: "operator|=(QBitArray)"
            rename: "or"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QBitArray"
                }
            }
        }
        ModifyFunction{
            signature: "operator~()const"
            rename: "inverted"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QBitArray"
                }
            }
        }
        ModifyFunction{
            signature: "bits()const"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.nio.ByteBuffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = %env->NewDirectByteBuffer(const_cast<char*>(%in), jlong(__qt_this->size())/8 + ( jlong(__qt_this->size()) % 8 == 0 ? 0 : 1 ));\n"+
                                  "%out = Java::Runtime::ByteBuffer::asReadOnlyBuffer(%env, %out);"}
                }
            }
        }
        ModifyFunction{
            signature: "fromBits(const char *, qsizetype)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            ModifyArgument{
                index: 2
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "qsizetype %out = qMin<qsizetype>(%in, __qt_%1.size()*8);"}
                }
            }
            since: [5, 10]
        }
        ModifyFunction{
            signature: "toUInt32(QSysInfo::Endian,bool *)const"
            rename: "toInteger"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.lang.Integer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = ok ? qtjambi_cast<jobject>(%env, %in) : nullptr;"}
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "bool ok = false;\n"+
                                  "bool* %out = &ok;"}
                }
            }
            since: 6
        }
    }
    
    
    EnumType{
        name: "QCborError::Code"
        since: [5, 12]
    }
    
    ValueType{
        name: "QCborError"
        ModifyField{
            name: "c"
            rename: "code"
        }
        ModifyFunction{
            signature: "operator Code() const"
            remove: RemoveFlag.All
        }
        since: [5, 12]
    }
    
    ValueType{
        name: "QCborParserError"
        since: [5, 12]
    }
    
    ValueType{
        name: "QCborValueConstRef"
        javaName: "QCborValue"
        generate: false
        since: [6, 4]
    }
    
    ValueType{
        name: "QCborValueRef"
        javaName: "QCborValue"
        generate: false
        since: [5, 12]
    }
    
    ValueType{
        name: "QCborValue"
        ExtraIncludes{
            Include{
                fileName: "utils_p.h"
                location: Include.Global
            }
        }
        ModifyFunction{
            signature: "QCborValue(QLatin1String)"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "QCborValue(QLatin1StringView)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "QCborValue(QStringView)"
            remove: RemoveFlag.All
            since: [5, 14]
        }
        ModifyFunction{
            signature: "QCborValue(const char*)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "QCborValue(std::nullptr_t)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "QCborValue(unsigned)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator[](QLatin1String)"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "operator[](QLatin1StringView)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "operator[](QLatin1String)const"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "operator[](QLatin1StringView)const"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "operator[](QString)const"
            rename: "value"
        }
        ModifyFunction{
            signature: "operator[](long long)const"
            rename: "value"
        }
        ModifyFunction{
            signature: "fromCbor(const char *, qsizetype, QCborParserError *)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "fromCbor(const unsigned char *, qsizetype, QCborParserError *)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator=(const QCborValue &)"
            rename: "set"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "void"
                }
            }
        }
        ModifyFunction{
            signature: "QCborValue(const QRegularExpression &)"
            ppCondition: "QT_CONFIG(regularexpression)"
        }
        ModifyFunction{
            signature: "toRegularExpression(const QRegularExpression &)const"
            ppCondition: "QT_CONFIG(regularexpression)"
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QCborValue_java__"
                quoteBeforeLine: "}// class"
            }
        }
        ModifyFunction{
            signature: "operator[](const QString &)"
            rename: "setValue"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "void"
                }
            }
            AddArgument{
                name: "value"
                type: "io.qt.core.QCborValue"
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.End
                ArgumentMap{
                    index: 0
                    metaName: "%0"
                }
                Text{content: "%0 = qtjambi_cast<const QCborValue&>(%env, value);"}
            }
        }
        ModifyFunction{
            signature: "operator[](long long)"
            rename: "setValue"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "void"
                }
            }
            AddArgument{
                name: "value"
                type: "io.qt.core.QCborValue"
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.End
                ArgumentMap{
                    index: 0
                    metaName: "%0"
                }
                Text{content: "%0 = qtjambi_cast<const QCborValue&>(%env, value);"}
            }
        }
        ModifyFunction{
            signature: "tag(QCborTag) const"
            ModifyArgument{
                index: 1
                ReplaceDefaultExpression{
                    expression: "QCborTag.resolve(-1)"
                }
            }
        }
        ModifyFunction{
            signature: "fromCbor(const QByteArray &, QCborParserError *)"
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QCborParserError %in;\n"+
                                  "QCborParserError* %out = &%in;"}
                }
            }
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "io.qt.core.QCborValue$FromCborResult"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = Java::QtCore::QCborValue$FromCborResult::newInstance(%env, qtjambi_cast<jobject>(%env, %in), qtjambi_cast<jobject>(%env, %2));"}
                }
            }
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.util.concurrent.atomic.AtomicReference<QCborParserError>"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    InsertTemplate{
                        name: "core.AtomicReference_to_ptr"
                        Replace{
                            from: "%TYPE"
                            to: "QCborParserError"
                        }
                    }
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    InsertTemplate{
                        name: "core.ptr_to_AtomicReference"
                        Replace{
                            from: "%TYPE"
                            to: "QCborParserError"
                        }
                    }
                }
            }
        }
        since: [5, 12]
    }
    
    ValueType{
        name: "QCborArray"
        ModifyFunction{
            signature: "extract(QCborArray::ConstIterator)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "first()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "last()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "cend()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "cbegin()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "end()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "begin()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator[](qsizetype)const"
            rename: "value"
        }
        ModifyFunction{
            signature: "operator=(const QCborArray &)"
            rename: "set"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "void"
                }
            }
        }
        ModifyFunction{
            signature: "operator+(QCborValue) const"
            rename: "plus"
        }
        ModifyFunction{
            signature: "operator+=(QCborValue)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator<<(QCborValue)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator[](qsizetype)"
            rename: "setValueAt"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "void"
                }
            }
            AddArgument{
                name: "value"
                type: "io.qt.core.QCborValue"
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.End
                ArgumentMap{
                    index: 0
                    metaName: "%0"
                }
                Text{content: "%0 = qtjambi_cast<const QCborValue&>(%env, value);"}
            }
        }
        since: [5, 12]
    }
    
    EnumType{
        name: "QCborSimpleType"
        since: [5, 12]
    }
    
    EnumType{
        name: "QCborTag"
        extensible: true
        since: [5, 12]
    }
    
    EnumType{
        name: "QCborKnownTags"
        since: [5, 12]
    }
    
    EnumType{
        name: "QCborValue::EncodingOption"
        flags: "QCborValue::EncodingOptions"
        since: [5, 12]
    }
    
    EnumType{
        name: "QCborValue::DiagnosticNotationOption"
        flags: "QCborValue::DiagnosticNotationOptions"
        since: [5, 12]
    }
    
    EnumType{
        name: "QCborValue::Type"
        since: [5, 12]
    }
    
    IteratorType{
        name: "QCborArray::ConstIterator"
        since: [5, 12]
    }
    
    ValueType{
        name: "QCborMap"
        ModifyFunction{
            signature: "erase(QCborMap::Iterator)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "extract(QCborMap::Iterator)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "erase(QCborMap::ConstIterator)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "extract(QCborMap::ConstIterator)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "end()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "cend()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "begin()"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "end()"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "begin()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "cbegin()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "contains(QLatin1StringView)const"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "contains(QLatin1String) const"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "constFind(QLatin1String) const"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "constFind(QLatin1StringView) const"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "find(QLatin1String)"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "find(QLatin1StringView)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "find(QLatin1String) const"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "find(QLatin1StringView)const"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "find(QString)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "find(QCborValue)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "find(QCborValue)const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "find(QString)const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "find(long long)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "find(long long)const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "insert(QLatin1StringView,QCborValue)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "insert(QLatin1String,QCborValue)"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "operator[](QLatin1StringView)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "operator[](QLatin1String)"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "operator[](QLatin1String)const"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "operator[](QLatin1StringView)const"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "operator[](QString)const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator[](QCborValue)const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator[](long long)const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "remove(QLatin1StringView)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "remove(QLatin1String)"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "take(QLatin1String)"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "take(QLatin1StringView)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "value(QLatin1String)const"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "value(QLatin1StringView)const"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "operator=(const QCborMap &)"
            rename: "set"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "void"
                }
            }
        }
        ModifyFunction{
            signature: "insert(QString,QCborValue)"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QCborMap"
                }
            }
        }
        ModifyFunction{
            signature: "insert(long long,QCborValue)"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QCborMap"
                }
            }
        }
        ModifyFunction{
            signature: "insert(QCborValue,QCborValue)"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QCborMap"
                }
            }
        }
        ModifyFunction{
            signature: "insert(QPair<QCborValue,QCborValue>)"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QCborMap"
                }
            }
        }
        ModifyFunction{
            signature: "operator[](QCborValue)"
            rename: "setValue"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "void"
                }
            }
            AddArgument{
                name: "value"
                type: "io.qt.core.QCborValue"
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.End
                ArgumentMap{
                    index: 0
                    metaName: "%0"
                }
                Text{content: "%0 = qtjambi_cast<const QCborValue&>(%env, value);"}
            }
        }
        ModifyFunction{
            signature: "operator[](const QString &)"
            rename: "setValue"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "void"
                }
            }
            AddArgument{
                name: "value"
                type: "io.qt.core.QCborValue"
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.End
                ArgumentMap{
                    index: 0
                    metaName: "%0"
                }
                Text{content: "%0 = qtjambi_cast<const QCborValue&>(%env, value);"}
            }
        }
        ModifyFunction{
            signature: "operator[](long long)"
            rename: "setValue"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "void"
                }
            }
            AddArgument{
                name: "value"
                type: "io.qt.core.QCborValue"
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.End
                ArgumentMap{
                    index: 0
                    metaName: "%0"
                }
                Text{content: "%0 = qtjambi_cast<const QCborValue&>(%env, value);"}
            }
        }
        since: [5, 12]
    }
    
    IteratorType{
        name: "QCborMap::ConstIterator"
        since: [5, 12]
    }
    
    IteratorType{
        name: "QCborMap::Iterator"
        since: [5, 12]
    }
    
    ObjectType{
        name: "QCborStreamReader::StringResult"
        disableNativeIdUsage: true
        template: true
        ModifyFunction{
            signature: "StringResult()"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "StringResult(StringResult)"
            remove: RemoveFlag.All
        }
        TemplateArguments{
            arguments: ["QVariant"]
        }
        since: [5, 12]
    }
    
    ObjectType{
        name: "QCborStreamReader::StringResult<QVariant>"
        isGeneric: true
        generate: "no-shell"
        ModifyFunction{
            signature: "StringResult<QVariant>()"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "StringResult<QVariant>(StringResult<QVariant>)"
            remove: RemoveFlag.All
        }
        ModifyField{
            name: "data"
            read: true
            write: false
        }
        ModifyField{
            name: "status"
            read: true
            write: false
        }
        since: [5, 12]
    }
    
    ObjectType{
        name: "QCborStreamReader"
        ExtraIncludes{
            Include{
                fileName: "utils_p.h"
                location: Include.Local
            }
        }
        ModifyFunction{
            signature: "QCborStreamReader(const unsigned char *, qsizetype)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "isNegativeInteger()const"
            remove: RemoveFlag.All
        }
        ExtraIncludes{
            Include{
                fileName: "utils_p.h"
                location: Include.Local
            }
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QCborStreamReader_java__"
                quoteBeforeLine: "}// class"
            }
        }
        ModifyFunction{
            signature: "QCborStreamReader(QIODevice *)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcDevice"
                    action: ReferenceCount.Set
                }
            }
        }
        ModifyFunction{
            signature: "isFloat16()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "toFloat16()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "isBool()const"
            rename: "isBoolean"
        }
        ModifyFunction{
            signature: "toBool()const"
            rename: "toBoolean"
        }
        ModifyFunction{
            signature: "setDevice(QIODevice *)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcDevice"
                    action: ReferenceCount.Set
                }
            }
        }
        ModifyFunction{
            signature: "QCborStreamReader(const char *, qsizetype)"
            ModifyArgument{
                index: 1
                ArrayType{
                    asBuffer: true
                }
            }
            InjectCode{
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                Text{content: "if(!%1.isDirect()) {\n"+
                              "    throw new IllegalArgumentException(\"Can only read from direct buffers.\");\n"+
                              "}\n"+
                              "__rcDevice = %1;"}
            }
        }
        ModifyFunction{
            signature: "addData(const unsigned char *, qsizetype)"
            ModifyArgument{
                index: 1
                ArrayType{
                    asBuffer: true
                }
            }
            InjectCode{
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                Text{content: "if(!%1.isDirect()) {\n"+
                              "    throw new IllegalArgumentException(\"Can only read from direct buffers.\");\n"+
                              "}\n"+
                              "__rcDevice = new QPair<>(__rcDevice, %1);"}
            }
        }
        ModifyFunction{
            signature: "addData(const char *, qsizetype)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "isUnsignedInteger()const"
            rename: "isBigInteger"
            InjectCode{
                target: CodeClass.Native
                position: Position.Beginning
                Text{content: "if(__qt_this->isNegativeInteger())\n"+
                              "    __java_return_value = true;\n"+
                              "else"}
            }
        }
        ModifyFunction{
            signature: "toFloat()const"
            InjectCode{
                target: CodeClass.Native
                position: Position.Beginning
                Text{content: "if(__qt_this->isFloat16())\n"+
                              "    __java_return_value = jfloat(__qt_this->toFloat16());\n"+
                              "else"}
            }
        }
        ModifyFunction{
            signature: "isFloat()const"
            InjectCode{
                target: CodeClass.Native
                position: Position.Beginning
                Text{content: "if(__qt_this->isFloat16())\n"+
                              "    __java_return_value = true;\n"+
                              "else"}
            }
        }
        ModifyFunction{
            signature: "toUnsignedInteger()const"
            rename: "toBigInteger"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.math.BigInteger"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = toBigInteger(%env, %in, false);\n"+
                                  "}"}
                }
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.Beginning
                Text{content: "if(__qt_this->isNegativeInteger()){\n"+
                              "    __java_return_value = toBigInteger(%env, quint64(__qt_this->toNegativeInteger()), true);\n"+
                              "}else{"}
            }
        }
        ModifyFunction{
            signature: "readString()"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "io.qt.core.QCborStreamReader.StringResult<String>"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QCborStreamReader::StringResult<QVariant>* _%in = new QCborStreamReader::StringResult<QVariant>;\n"+
                                  "_%in->data = %in.data;\n"+
                                  "_%in->status = %in.status;\n"+
                                  "%out = QtJambiAPI::convertNativeToJavaObject(%env, _%in, false);"}
                }
            }
        }
        ModifyFunction{
            signature: "readByteArray()"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "io.qt.core.QCborStreamReader.StringResult<io.qt.core.QByteArray>"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QCborStreamReader::StringResult<QVariant>* _%in = new QCborStreamReader::StringResult<QVariant>;\n"+
                                  "_%in->data = %in.data;\n"+
                                  "_%in->status = %in.status;\n"+
                                  "%out = QtJambiAPI::convertNativeToJavaObject(%env, _%in, false);"}
                }
            }
        }
        ModifyFunction{
            signature: "readStringChunk(char *, qsizetype)"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "io.qt.core.QCborStreamReader.StringResult<Long>"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QCborStreamReader::StringResult<QVariant>* _%in = new QCborStreamReader::StringResult<QVariant>;\n"+
                                  "_%in->data = qint64(%in.data);\n"+
                                  "_%in->status = %in.status;\n"+
                                  "%out = QtJambiAPI::convertNativeToJavaObject(%env, _%in, false);"}
                }
            }
            ModifyArgument{
                index: 1
                ArrayType{
                    asBuffer: true
                }
            }
            InjectCode{
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                Text{content: "if(!%1.isDirect()) {\n"+
                              "    throw new IllegalArgumentException(\"Can only read from direct buffers.\");\n"+
                              "}"}
            }
        }
        since: [5, 12]
    }
    
    ObjectType{
        name: "QCborStreamWriter"
        ModifyFunction{
            signature: "QCborStreamWriter(QIODevice *)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcDevice"
                    action: ReferenceCount.Set
                }
            }
        }
        ModifyFunction{
            signature: "setDevice(QIODevice *)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcDevice"
                    action: ReferenceCount.Set
                }
            }
        }
        ModifyFunction{
            signature: "append(QLatin1StringView)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "append(QLatin1String)"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "append(unsigned int)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "append(qfloat16)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "append(std::nullptr_t)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "appendTextString(const char *, qsizetype)"
            remove: RemoveFlag.All
        }
        ExtraIncludes{
            Include{
                fileName: "utils_p.h"
                location: Include.Local
            }
        }
        ModifyFunction{
            signature: "append(const char *, qsizetype)"
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
        }
        ModifyFunction{
            signature: "append(unsigned long long)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.math.BigInteger"
                }
                NoNullPointer{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "BigIntegerValue bigIntegerValue = fromBigInteger(%env, %in);\n"+
                                  "if(bigIntegerValue.outOfRange){\n"+
                                  "    Java::Runtime::ArithmeticException::throwNew(%env, \"BigInteger is out of range of 64 Bit.\" QTJAMBI_STACKTRACEINFO );\n"+
                                  "    return;\n"+
                                  "}\n"+
                                  "if(bigIntegerValue.isNegative){\n"+
                                  "    __qt_this->append(QCborNegativeInteger(bigIntegerValue.value));\n"+
                                  "    return;\n"+
                                  "}\n"+
                                  "quint64 %out = bigIntegerValue.value;"}
                }
            }
        }
        ModifyFunction{
            signature: "appendByteString(const char *, qsizetype)"
            rename: "append"
            ModifyArgument{
                index: 1
                ArrayType{
                    asBuffer: true
                }
            }
        }
        ModifyFunction{
            signature: "QCborStreamWriter(QByteArray *)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
                NoNullPointer{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QByteArray* %out = qtjambi_cast<QByteArray*>(%env, %in);"}
                }
                ReferenceCount{
                    variableName: "__rcDevice"
                    action: ReferenceCount.Set
                }
            }
        }
        since: [5, 12]
    }
    
    EnumType{
        name: "QCborStreamReader::Type"
        RejectEnumValue{
            name: "ByteString"
        }
        RejectEnumValue{
            name: "TextString"
        }
        RejectEnumValue{
            name: "HalfFloat"
        }
        since: [5, 12]
    }
    
    EnumType{
        name: "QCborStreamReader::StringResultCode"
        since: [5, 12]
    }
    
    ValueType{
        name: "QJsonArray"
        ModifyFunction{
            signature: "insert(QJsonArray::iterator,QJsonValue)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator=(const QJsonArray&)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator+=(const QJsonValue &)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator+(const QJsonValue &) const"
            rename: "plus"
        }
        ModifyFunction{
            signature: "operator[](int) const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "operator[](int)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "operator[](qsizetype) const"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "operator[](qsizetype)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "operator<<(const QJsonValue &)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "toVariantList()const"
            rename: "toList"
        }
        ModifyFunction{
            signature: "begin()"
            remove: RemoveFlag.All
            since: [5, 7]
        }
        ModifyFunction{
            signature: "end()"
            remove: RemoveFlag.All
            since: [5, 7]
        }
        ModifyFunction{
            signature: "begin() const"
            remove: RemoveFlag.All
            since: [5, 7]
        }
        ModifyFunction{
            signature: "end() const"
            remove: RemoveFlag.All
            since: [5, 7]
        }
        ModifyFunction{
            signature: "cbegin() const"
            remove: RemoveFlag.All
            since: [5, 14]
        }
        ModifyFunction{
            signature: "cend() const"
            remove: RemoveFlag.All
            since: [5, 14]
        }
    }
    
    IteratorType{
        name: "QJsonArray::const_iterator"
    }
    IteratorType{
        name: "QJsonArray::iterator"
        isConst: true
    }
    
    ValueType{
        name: "QJsonDocument"
        ModifyFunction{
            signature: "operator=(const QJsonDocument&)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator[](QLatin1String) const"
            remove: RemoveFlag.All
            since: [5, 10]
            until: [6, 3]
        }
        ModifyFunction{
            signature: "operator[](QLatin1StringView) const"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "operator[](const QString &) const"
            rename: "getObjectValue"
            since: [5, 10]
            until: [5, 13, 0]
        }
        ModifyFunction{
            signature: "operator[](const QString &)const"
            remove: RemoveFlag.All
            since: [5, 14]
        }
        ModifyFunction{
            signature: "operator[](QStringView)const"
            rename: "getObjectValue"
            since: [5, 14]
        }
        ModifyFunction{
            signature: "operator[](int) const"
            rename: "getArrayValue"
            since: [5, 10]
            until: 5
        }
        ModifyFunction{
            signature: "operator[](qsizetype) const"
            rename: "getArrayValue"
            since: 6
        }
        ExtraIncludes{
            Include{
                fileName: "utils_p.h"
                location: Include.Local
            }
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QJsonDocument___"
                quoteBeforeLine: "}// class"
            }
        }
        InjectCode{
            until: 5
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QJsonDocument_5__"
                quoteBeforeLine: "}// class"
            }
        }
        ModifyFunction{
            signature: "rawData(int*)const"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "byte[]"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jbyteArray %out = %env->NewByteArray(%1);\n"+
                                  "%env->SetByteArrayRegion(%out, 0, %1, reinterpret_cast<const jbyte *>(%in));"}
                }
            }
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "int %in = 0;\n"+
                                  "int* %out = &%in;"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "fromJson(const QByteArray &, QJsonParseError *)"
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QJsonParseError error;\n"+
                                  "QJsonParseError* %out = &error;"}
                }
            }
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "io.qt.core.QJsonDocument$FromJsonResult"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = Java::QtCore::QJsonDocument$FromJsonResult::newInstance(%env, qtjambi_cast<jobject>(%env, %in), qtjambi_cast<jobject>(%env, error));"}
                }
            }
        }
        ModifyFunction{
            signature: "fromRawData(const char *, int, QJsonDocument::DataValidation)"
            ModifyArgument{
                index: 1
                ArrayType{
                    asBuffer: true
                }
            }
            ModifyArgument{
                index: 2
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "int %out = %in>=0 ? qMin(int(%in), int(__qt_%1_buffer.size())) : int(__qt_%1_buffer.size());"}
                }
            }
            until: 5
        }
    }
    
    ValueType{
        name: "QJsonObject"
        ModifyFunction{
            signature: "insert(QLatin1String,QJsonValue)"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "insert(QLatin1StringView,QJsonValue)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "insert(QStringView,QJsonValue)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "insert(QString,QJsonValue)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator=(const QJsonObject&)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator[](const QString &) const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator[](QLatin1String) const"
            remove: RemoveFlag.All
            since: [5, 7]
            until: [6, 3]
        }
        ModifyFunction{
            signature: "operator[](QLatin1StringView) const"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "operator[](QLatin1String)"
            remove: RemoveFlag.All
            since: [5, 7]
            until: [6, 3]
        }
        ModifyFunction{
            signature: "operator[](QLatin1StringView)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "operator[](QStringView) const"
            remove: RemoveFlag.All
            since: [5, 14]
        }
        ModifyFunction{
            signature: "operator[](QStringView)"
            remove: RemoveFlag.All
            since: [5, 14]
        }
        ModifyFunction{
            signature: "value(QLatin1StringView) const"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "value(QLatin1String) const"
            remove: RemoveFlag.All
            since: [5, 7]
            until: [6, 3]
        }
        ModifyFunction{
            signature: "value(QString) const"
            remove: RemoveFlag.All
            since: [5, 14]
        }
        ModifyFunction{
            signature: "contains(QLatin1String) const"
            remove: RemoveFlag.All
            since: [5, 7]
            until: [6, 3]
        }
        ModifyFunction{
            signature: "contains(QLatin1StringView)const"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "constFind(const QString &) const"
            remove: RemoveFlag.All
            since: [5, 14]
        }
        ModifyFunction{
            signature: "constFind(QLatin1StringView) const"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "constFind(QLatin1String) const"
            remove: RemoveFlag.All
            since: [5, 7]
            until: [6, 3]
        }
        ModifyFunction{
            signature: "find(QLatin1StringView)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "find(QLatin1String)"
            remove: RemoveFlag.All
            since: [5, 7]
            until: [6, 3]
        }
        ModifyFunction{
            signature: "find(QString)"
            remove: RemoveFlag.All
            since: [5, 14]
        }
        ModifyFunction{
            signature: "find(QLatin1StringView)const"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "find(QLatin1String) const"
            remove: RemoveFlag.All
            since: [5, 7]
            until: [6, 3]
        }
        ModifyFunction{
            signature: "find(QString) const"
            remove: RemoveFlag.All
            since: [5, 14]
        }
        ModifyFunction{
            signature: "find(QStringView) const"
            remove: RemoveFlag.All
            since: [5, 14]
        }
        ModifyFunction{
            signature: "remove(QLatin1StringView)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "remove(QLatin1String)"
            remove: RemoveFlag.All
            since: [5, 14]
            until: [6, 3]
        }
        ModifyFunction{
            signature: "remove(QString)"
            remove: RemoveFlag.All
            since: [5, 14]
        }
        ModifyFunction{
            signature: "contains(QString) const"
            remove: RemoveFlag.All
            since: [5, 14]
        }
        ModifyFunction{
            signature: "take(QLatin1StringView)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "take(QLatin1String)"
            remove: RemoveFlag.All
            since: [5, 14]
            until: [6, 3]
        }
        ModifyFunction{
            signature: "take(QString)"
            remove: RemoveFlag.All
            since: [5, 14]
        }
        ModifyFunction{
            signature: "begin()"
            remove: RemoveFlag.All
            since: [5, 7]
        }
        ModifyFunction{
            signature: "end()"
            remove: RemoveFlag.All
            since: [5, 7]
        }
        ModifyFunction{
            signature: "begin() const"
            remove: RemoveFlag.All
            since: [5, 7]
        }
        ModifyFunction{
            signature: "end() const"
            remove: RemoveFlag.All
            since: [5, 7]
        }
        ModifyFunction{
            signature: "operator[](const QString &)"
            rename: "setValue"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "void"
                }
            }
            AddArgument{
                name: "value"
                type: "io.qt.core.QJsonValue"
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.End
                ArgumentMap{
                    index: 0
                    metaName: "%0"
                }
                Text{content: "%0 = qtjambi_cast<const QJsonValue&>(%env, value);"}
            }
        }
        ModifyFunction{
            signature: "fromVariantMap(const QMap<QString,QVariant> &)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.util.NavigableMap<java.lang.String, java.lang.Object>"
                }
            }
        }
    }
    
    IteratorType{
        name: "QJsonObject::const_iterator"
    }

    IteratorType{
        name: "QJsonObject::iterator"
        isConst: true
    }
    
    ValueType{
        name: "QJsonParseError"
    }
    
    ValueType{
        name: "QJsonValueConstRef"
        javaName: "QJsonValue"
        generate: false
        since: [6, 4]
    }
    
    ValueType{
        name: "QJsonValueRef"
        javaName: "QJsonValue"
        generate: false
    }
    
    ValueType{
        name: "QJsonValue"
        ModifyFunction{
            signature: "QJsonValue(QLatin1StringView)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "QJsonValue(QLatin1String)"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "QJsonValue(const char*)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator=(QJsonValue)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "toBool(bool)const"
            rename: "toBoolean"
        }
        ModifyFunction{
            signature: "operator[](QLatin1String) const"
            remove: RemoveFlag.All
            since: [5, 10]
            until: [6, 3]
        }
        ModifyFunction{
            signature: "operator[](QLatin1StringView) const"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "operator[](const QString &) const"
            rename: "getObjectValue"
            since: [5, 10]
            until: [5, 13, 0]
        }
        ModifyFunction{
            signature: "operator[](const QString &)const"
            remove: RemoveFlag.All
            since: [5, 14]
        }
        ModifyFunction{
            signature: "operator[](QStringView)const"
            rename: "getObjectValue"
            since: [5, 14]
        }
        ModifyFunction{
            signature: "operator[](int) const"
            rename: "getArrayValue"
            since: [5, 10]
            until: 5
        }
        ModifyFunction{
            signature: "operator[](qsizetype) const"
            rename: "getArrayValue"
            since: 6
        }
    }
    
    ValueType{
        name: "QMimeType"
        ModifyFunction{
            signature: "operator=(QMimeType)"
            remove: RemoveFlag.All
        }
    }
    
    EnumType{
        name: "QRegularExpression::WildcardConversionOption"
        flags: "QRegularExpression::WildcardConversionOptions"
        since: 6
    }
    
    ValueType{
        name: "QRegularExpression"
        ModifyFunction{
            signature: "operator=(QRegularExpression)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "anchoredPattern(QStringView)"
            remove: RemoveFlag.All
            since: [5, 15]
        }
        ModifyFunction{
            signature: "wildcardToRegularExpression(QStringView)"
            remove: RemoveFlag.All
            since: [5, 15]
            until: 5
        }
        ModifyFunction{
            signature: "wildcardToRegularExpression(QStringView,QFlags<QRegularExpression::WildcardConversionOption>)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "escape(QStringView)"
            remove: RemoveFlag.All
            since: [5, 15]
        }
        ModifyFunction{
            signature: "globalMatch(const QStringRef &, int, QRegularExpression::MatchType, QFlags<QRegularExpression::MatchOption>) const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "globalMatch(QString, int, QRegularExpression::MatchType, QFlags<QRegularExpression::MatchOption>) const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "globalMatch(QString, qsizetype, QRegularExpression::MatchType, QFlags<QRegularExpression::MatchOption>) const"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "match(const QStringRef &, int, QRegularExpression::MatchType, QFlags<QRegularExpression::MatchOption>) const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "match(QString, int, QRegularExpression::MatchType, QFlags<QRegularExpression::MatchOption>) const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "match(QString, qsizetype, QRegularExpression::MatchType, QFlags<QRegularExpression::MatchOption>) const"
            remove: RemoveFlag.All
            since: 6
        }
    }
    
    ValueType{
        name: "QRegularExpressionMatch"
        ModifyFunction{
            signature: "QRegularExpressionMatch(QRegularExpressionMatch)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator=(QRegularExpressionMatch)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "captured(QStringView) const"
            remove: RemoveFlag.All
            since: [5, 10]
        }
        ModifyFunction{
            signature: "capturedEnd(QStringView) const"
            remove: RemoveFlag.All
            since: [5, 10]
        }
        ModifyFunction{
            signature: "capturedLength(QStringView) const"
            remove: RemoveFlag.All
            since: [5, 10]
        }
        ModifyFunction{
            signature: "capturedRef(int) const"
            remove: RemoveFlag.All
            since: [5, 10]
            until: 5
        }
        ModifyFunction{
            signature: "capturedRef(QStringView) const"
            remove: RemoveFlag.All
            since: [5, 10]
            until: 5
        }
        ModifyFunction{
            signature: "capturedRef(const QString &) const"
            remove: RemoveFlag.All
            since: [5, 10]
            until: 5
        }
        ModifyFunction{
            signature: "capturedStart(QStringView) const"
            remove: RemoveFlag.All
            since: [5, 10]
        }
        ModifyFunction{
            signature: "capturedView(QStringView) const"
            remove: RemoveFlag.All
            since: [5, 10]
        }
        ModifyFunction{
            signature: "hasCaptured(QStringView) const"
            remove: RemoveFlag.All
            since: [6, 3]
        }
        ModifyFunction{
            signature: "capturedView(int) const"
            remove: RemoveFlag.All
            since: [5, 10]
        }
    }
    
    ValueType{
        name: "QRegularExpressionMatchIterator"
        implementing: "Iterable<QRegularExpressionMatch>, java.util.Iterator<QRegularExpressionMatch>"
        ModifyFunction{
            signature: "QRegularExpressionMatchIterator(QRegularExpressionMatchIterator)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator=(QRegularExpressionMatchIterator)"
            remove: RemoveFlag.All
        }
        InjectCode{
            InsertTemplate{
                name: "core.self_iterator"
                Replace{
                    from: "%ELEMENT_TYPE"
                    to: "QRegularExpressionMatch"
                }
            }
        }
    }
    
    ValueType{
        name: "QUrlQuery"
        ModifyFunction{
            signature: "operator=(QUrlQuery)"
            remove: RemoveFlag.All
        }
    }
    
    ValueType{
        name: "QTimeZone"
        ModifyFunction{
            signature: "operator=(QTimeZone)"
            remove: RemoveFlag.All
        }
        InjectCode{
            target: CodeClass.Java
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QTimeZone___"
                quoteBeforeLine: "}// class"
            }
        }
    }
    
    ValueType{
        name: "QTimeZone::OffsetData"
    }

    EnumType{
        name: "QTimeZone::Initialization"
        since: [6,5]
    }
    
    
    ObjectType{
        name: "QStandardPaths"
        ModifyFunction{
            signature: "findExecutable(const QString &, const QStringList &)"
            ModifyArgument{
                index: 2
                ReplaceDefaultExpression{
                    expression: "new java.util.ArrayList<String>()"
                }
            }
        }
    }
    
    ObjectType{
        name: "QSaveFile"
    }
    
    
    ObjectType{
        name: "QMimeDatabase"
    }
    
    ObjectType{
        name: "QEventLoopLocker"
    }
    
    ObjectType{
        name: "QDirIterator"
        implementing: "Iterable<String>, java.util.Iterator<String>"
        InjectCode{
            InsertTemplate{
                name: "core.self_iterator"
                Replace{
                    from: "%ELEMENT_TYPE"
                    to: "String"
                }
            }
        }
    }
    
    
    ObjectType{
        name: "QAbstractItemModel"
        isValueOwner: true
        ModifyFunction{
            signature: "beginInsertColumns(const QModelIndex &, int, int)"
            access: Modification.NonFinal
        }
        ModifyFunction{
            signature: "beginInsertRows(const QModelIndex &, int, int)"
            access: Modification.NonFinal
        }
        ModifyFunction{
            signature: "beginRemoveColumns(const QModelIndex &, int, int)"
            access: Modification.NonFinal
        }
        ModifyFunction{
            signature: "beginRemoveColumns(const QModelIndex &, int, int)"
            access: Modification.NonFinal
        }
        ModifyFunction{
            signature: "beginRemoveRows(const QModelIndex &, int, int)"
            access: Modification.NonFinal
        }
        ModifyFunction{
            signature: "beginResetModel()"
            access: Modification.NonFinal
        }
        ModifyFunction{
            signature: "endInsertColumns()"
            access: Modification.NonFinal
        }
        ModifyFunction{
            signature: "endInsertRows()"
            access: Modification.NonFinal
        }
        ModifyFunction{
            signature: "endRemoveColumns()"
            access: Modification.NonFinal
        }
        ModifyFunction{
            signature: "endRemoveRows()"
            access: Modification.NonFinal
        }
        ModifyFunction{
            signature: "endResetModel()"
            access: Modification.NonFinal
        }
        ModifyFunction{
            signature: "resetInternalData()"
            access: Modification.NonFinal
            virtualSlot: true
            until: 5
        }
        ModifyFunction{
            signature: "parent()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "createIndex(int, int, void *) const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "createIndex(int, int, const void*) const"
            remove: RemoveFlag.All
            since: 6
        }
        ExtraIncludes{
            Include{
                fileName: "QStringList"
                location: Include.Global
            }
            Include{
                fileName: "QSize"
                location: Include.Global
            }
        }
        ModifyFunction{
            signature: "match(QModelIndex,int,QVariant,int,QFlags<Qt::MatchFlag>)const"
            ModifyArgument{
                index: 5
                ReplaceDefaultExpression{
                    expression: "Qt.MatchFlag.MatchStartsWith, Qt.MatchFlag.MatchWrap"
                }
            }
        }
        InjectCode{
            target: CodeClass.Java
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QAbstractItemModel___"
                quoteBeforeLine: "}// class"
            }
        }
        ModifyFunction{
            signature: "mimeData(QList<QModelIndex>)const"
            ModifyArgument{
                index: 0
                DefineOwnership{
                    codeClass: CodeClass.Shell
                    ownership: Ownership.Cpp
                }
                DefineOwnership{
                    codeClass: CodeClass.Native
                    ownership: Ownership.Java
                }
            }
        }
        ModifyFunction{
            signature: "canDropMimeData(const QMimeData *, Qt::DropAction,int, int, const QModelIndex &)const"
            ModifyArgument{
                index: 1
                NoNullPointer{
                }
            }
        }
    }
    
    ObjectType{
        name: "QAbstractListModel"
        ExtraIncludes{
            Include{
                fileName: "QStringList"
                location: Include.Global
            }
            Include{
                fileName: "QSize"
                location: Include.Global
            }
        }
        ModifyFunction{
            signature: "parent()const"
            remove: RemoveFlag.All
        }
    }
    
    ObjectType{
        name: "QAbstractTableModel"
        ExtraIncludes{
            Include{
                fileName: "QStringList"
                location: Include.Global
            }
            Include{
                fileName: "QSize"
                location: Include.Global
            }
        }
        ModifyFunction{
            signature: "parent()const"
            remove: RemoveFlag.All
        }
    }
    
    ObjectType{
        name: "QStringListModel"
    }
    
    ValueType{
        name: "QUrl::FormattingOptions"
        disableNativeIdUsage: true
        generate: false
    }
    
    ValueType{
        name: "QUrl"
        ExtraIncludes{
            Include{
                fileName: "QStringList"
                location: Include.Global
            }
        }
        ModifyFunction{
            signature: "operator=(QUrl)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator=(QString)"
            remove: RemoveFlag.All
        }
        ExtraIncludes{
            Include{
                fileName: "QtJambi/JavaAPI"
                location: Include.Global
            }
        }
        InjectCode{
            target: CodeClass.Java
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QUrl___"
                quoteBeforeLine: "}// class"
            }
        }
        ModifyFunction{
            signature: "toStringList(const QList<QUrl> &,QUrl::FormattingOptions)"
            ModifyArgument{
                index: 2
                ReplaceDefaultExpression{
                    expression: "new FormattingOptions(ComponentFormattingOption.PrettyDecoded)"
                }
            }
        }
        ModifyFunction{
            signature: "toDisplayString(QUrl::FormattingOptions) const"
            ModifyArgument{
                index: 1
                ReplaceDefaultExpression{
                    expression: "new FormattingOptions(ComponentFormattingOption.PrettyDecoded)"
                }
            }
        }
        ModifyFunction{
            signature: "toEncoded(QUrl::FormattingOptions) const"
            ModifyArgument{
                index: 1
                ReplaceDefaultExpression{
                    expression: "new FormattingOptions(ComponentFormattingOption.PrettyDecoded)"
                }
            }
        }
        ModifyFunction{
            signature: "url(QUrl::FormattingOptions) const"
            ModifyArgument{
                index: 1
                ReplaceDefaultExpression{
                    expression: "new FormattingOptions(ComponentFormattingOption.PrettyDecoded)"
                }
            }
        }
        ModifyFunction{
            signature: "toString(QUrl::FormattingOptions) const"
            ModifyArgument{
                index: 1
                ReplaceDefaultExpression{
                    expression: "new FormattingOptions(ComponentFormattingOption.PrettyDecoded)"
                }
            }
        }
    }
    
    ValueType{
        name: "QRegExp"
        ExtraIncludes{
            Include{
                fileName: "QStringList"
                location: Include.Global
            }
        }
        ModifyFunction{
            signature: "operator=(QRegExp)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "pos(int)const"
            Remove{
            }
        }
        ModifyFunction{
            signature: "cap(int)const"
            Remove{
            }
        }
        ModifyFunction{
            signature: "capturedTexts()const"
            Remove{
            }
        }
        ModifyFunction{
            signature: "errorString()const"
            Remove{
            }
        }
    }
    
    ValueType{
        name: "QFileInfo"
        ExtraIncludes{
            Include{
                fileName: "QDateTime"
                location: Include.Global
            }
            Include{
                fileName: "QDir"
                location: Include.Global
            }
        }
        ModifyFunction{
            signature: "operator!=(const QFileInfo &)const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator=(QFileInfo)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "setFile(QFile)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    action: ReferenceCount.Ignore
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "readLink()const"
            remove: RemoveFlag.All
            until: 5
        }
    }
    
    InterfaceType{
        name: "QFactoryInterface"
    }
    
    ValueType{
        name: "QByteArrayView"
        ModifyFunction{
            signature: "QByteArrayView(std::nullptr_t)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "constData()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator[](qsizetype)const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "toLong(bool*, int) const"
            remove: RemoveFlag.All
            since: [6, 3]
        }
        ModifyFunction{
            signature: "toLongLong(bool*, int) const"
            remove: RemoveFlag.All
            since: [6, 3]
        }
        ModifyFunction{
            signature: "toUInt(bool*, int) const"
            remove: RemoveFlag.All
            since: [6, 3]
        }
        ModifyFunction{
            signature: "toULong(bool*, int) const"
            remove: RemoveFlag.All
            since: [6, 3]
        }
        ModifyFunction{
            signature: "toULongLong(bool*, int) const"
            remove: RemoveFlag.All
            since: [6, 3]
        }
        ModifyFunction{
            signature: "toUShort(bool*, int) const"
            remove: RemoveFlag.All
            since: [6, 3]
        }
        ExtraIncludes{
            Include{
                fileName: "QtJambi/JavaAPI"
                location: Include.Global
            }
            Include{
                fileName: "utils_p.h"
                location: Include.Local
            }
        }
        ModifyFunction{
            signature: "data() const"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.nio.ByteBuffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = %env->NewDirectByteBuffer(const_cast<char*>(%in), jlong(__qt_this->size()));\n"+
                                  "%out = Java::Runtime::ByteBuffer::asReadOnlyBuffer(%env, %out);"}
                }
            }
        }
        InjectCode{
            target: CodeClass.Java
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QByteArrayView___"
                quoteBeforeLine: "}// class"
            }
        }
        ModifyFunction{
            signature: "toShort(bool*, int) const"
            throwing: "NumberFormatException"
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "bool ok(false);\n"+
                                  "bool* %out = &ok;"}
                }
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.End
                Text{content: "if(!ok)\n"+
                              "    Java::Runtime::NumberFormatException::throwNew(%env, \"Unable to parse number.\" QTJAMBI_STACKTRACEINFO );"}
            }
            since: [6, 3]
        }
        ModifyFunction{
            signature: "toInt(bool*, int) const"
            throwing: "NumberFormatException"
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "bool ok(false);\n"+
                                  "bool* %out = &ok;"}
                }
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.End
                Text{content: "if(!ok)\n"+
                              "    Java::Runtime::NumberFormatException::throwNew(%env, \"Unable to parse number.\" QTJAMBI_STACKTRACEINFO );"}
            }
            since: [6, 3]
        }
        ModifyFunction{
            signature: "toDouble(bool*) const"
            throwing: "NumberFormatException"
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "bool ok(false);\n"+
                                  "bool* %out = &ok;"}
                }
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.End
                Text{content: "if(!ok)\n"+
                              "    Java::Runtime::NumberFormatException::throwNew(%env, \"Unable to parse number.\" QTJAMBI_STACKTRACEINFO );"}
            }
            since: [6, 3]
        }
        ModifyFunction{
            signature: "toFloat(bool*) const"
            throwing: "NumberFormatException"
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "bool ok(false);\n"+
                                  "bool* %out = &ok;"}
                }
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.End
                Text{content: "if(!ok)\n"+
                              "    Java::Runtime::NumberFormatException::throwNew(%env, \"Unable to parse number.\" QTJAMBI_STACKTRACEINFO );"}
            }
            since: [6, 3]
        }
        InjectCode{
            target: CodeClass.Java
            position: Position.Equals
            Text{content: "if (other instanceof byte[]) {\n"+
                          "    other = new io.qt.core.QByteArrayView((byte[]) other);\n"+
                          "}else if (other instanceof java.nio.ByteBuffer) {\n"+
                          "    other = new io.qt.core.QByteArrayView((java.nio.ByteBuffer) other);\n"+
                          "}else if (other instanceof String) {\n"+
                          "    other = new io.qt.core.QByteArrayView((String) other);\n"+
                          "}"}
        }
        InjectCode{
            target: CodeClass.Java
            position: Position.Compare
            Text{content: "if (other instanceof byte[]) {\n"+
                          "    other = new io.qt.core.QByteArrayView((byte[]) other);\n"+
                          "}else if (other instanceof java.nio.ByteBuffer) {\n"+
                          "    other = new io.qt.core.QByteArrayView((java.nio.ByteBuffer) other);\n"+
                          "}else if (other instanceof String) {\n"+
                          "    other = new io.qt.core.QByteArrayView((String) other);\n"+
                          "}"}
        }
        since: 6
    }
    
    IteratorType{
        name: "QByteArrayView::const_iterator"
    }

    IteratorType{
        name: "QByteArrayView::iterator"
        isConst: true
    }
    
    TypeAliasType{
        name: "QByteArrayView::const_pointer"
    }
    
    TypeAliasType{
        name: "QByteArrayView::value_type"
    }
    
    ValueType{
        name: "QByteArray::FromBase64Result"
        generate: false
        since: [5, 15]
    }
    
    ValueType{
        name: "QByteArray"
        ModifyFunction{
            signature: "setNum(ulong, int)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "number(long, int)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "number(ulong, int)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "number(unsigned long long, int)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "setNum(long, int)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "number(long, int)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "begin()"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "end()"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "begin()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "end()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "count()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "data()"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "setRawData(const char *, unsigned int)"
            access: Modification.Protected
            until: 5
        }
        ModifyFunction{
            signature: "setRawData(const char *, qsizetype)"
            access: Modification.Protected
            since: 6
        }
        ModifyFunction{
            signature: "number(uint,int)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "number(unsigned long long,int)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator const char *()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator const void *()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator+=(const char*)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator[](int)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "operator[](int)const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "operator[](uint)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "operator[](uint)const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "operator[](qsizetype)const"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "operator[](qsizetype)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "push_back(char)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "push_back(const QByteArray&)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "push_back(const char*)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "push_front(char)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "push_front(const QByteArray&)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "push_front(const char*)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "setNum(uint,int)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "setNum(unsigned long long,int)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "setNum(unsigned short,int)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "toLong(bool*, int) const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "toLongLong(bool*, int) const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "toUInt(bool*, int) const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "toULong(bool*, int) const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "toULongLong(bool*, int) const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "toUShort(bool*, int) const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator+=(QByteArray)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator+=(QString)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "operator+=(char)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "simplified_helper(const QByteArray &)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "toLower_helper(const QByteArray &)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "toUpper_helper(const QByteArray &)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "trimmed_helper(const QByteArray &)"
            remove: RemoveFlag.All
        }
        InjectCode{
            target: CodeClass.Java
            position: Position.Equals
            since: 6
            Text{content: "if (other instanceof byte[]) {\n"+
                          "    other = new io.qt.core.QByteArrayView((byte[]) other);\n"+
                          "}else if (other instanceof java.nio.ByteBuffer) {\n"+
                          "    other = new io.qt.core.QByteArrayView((java.nio.ByteBuffer) other);\n"+
                          "}"}
        }
        InjectCode{
            target: CodeClass.Java
            position: Position.Compare
            since: 6
            Text{content: "if (other instanceof byte[]) {\n"+
                          "    other = new io.qt.core.QByteArrayView((byte[]) other);\n"+
                          "}else if (other instanceof java.nio.ByteBuffer) {\n"+
                          "    other = new io.qt.core.QByteArrayView((java.nio.ByteBuffer) other);\n"+
                          "}"}
        }
        InjectCode{
            target: CodeClass.Java
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QByteArray___"
                quoteBeforeLine: "}// class"
            }
        }
        InjectCode{
            target: CodeClass.Java
            until: 5
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QByteArray_5__"
                quoteBeforeLine: "}// class"
            }
        }
        InjectCode{
            target: CodeClass.Java
            since: [5, 12]
            until: 5
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QByteArray_5_12__"
                quoteBeforeLine: "}// class"
            }
        }
        InjectCode{
            since: [5, 15]
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QByteArray_5_15__"
                quoteBeforeLine: "}// class"
            }
        }
        InjectCode{
            target: CodeClass.Java
            since: 6
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QByteArray_6__"
                quoteBeforeLine: "}// class"
            }
        }
        InjectCode{
            target: CodeClass.Java
            since: [6, 3]
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QByteArray_63__"
                quoteBeforeLine: "}// class"
            }
        }
        ExtraIncludes{
            Include{
                fileName: "QtJambi/JavaAPI"
                location: Include.Global
            }
            Include{
                fileName: "utils_p.h"
                location: Include.Local
            }
        }
        ModifyFunction{
            signature: "operator+=(QByteArrayView)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "toShort(bool*, int) const"
            throwing: "NumberFormatException"
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "bool ok(false);\n"+
                                  "bool* %out = &ok;"}
                }
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.End
                Text{content: "if(!ok)\n"+
                              "    Java::Runtime::NumberFormatException::throwNew(%env, \"Unable to parse number.\" QTJAMBI_STACKTRACEINFO );"}
            }
        }
        ModifyFunction{
            signature: "toInt(bool*, int) const"
            throwing: "NumberFormatException"
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "bool ok(false);\n"+
                                  "bool* %out = &ok;"}
                }
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.End
                Text{content: "if(!ok)\n"+
                              "    Java::Runtime::NumberFormatException::throwNew(%env, \"Unable to parse number.\" QTJAMBI_STACKTRACEINFO );"}
            }
        }
        ModifyFunction{
            signature: "toDouble(bool*) const"
            throwing: "NumberFormatException"
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "bool ok(false);\n"+
                                  "bool* %out = &ok;"}
                }
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.End
                Text{content: "if(!ok)\n"+
                              "    Java::Runtime::NumberFormatException::throwNew(%env, \"Unable to parse number.\" QTJAMBI_STACKTRACEINFO );"}
            }
        }
        ModifyFunction{
            signature: "toFloat(bool*) const"
            throwing: "NumberFormatException"
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "bool ok(false);\n"+
                                  "bool* %out = &ok;"}
                }
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.End
                Text{content: "if(!ok)\n"+
                              "    Java::Runtime::NumberFormatException::throwNew(%env, \"Unable to parse number.\" QTJAMBI_STACKTRACEINFO );"}
            }
        }
        ModifyFunction{
            signature: "QByteArray(const char*,int)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            ModifyArgument{
                index: 2
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jsize %out = %in;\n"+
                                  "if(%out<0){\n"+
                                  "    if(qstrlen(__qt_%1)>__qt_%1.size()){\n"+
                                  "        %out = jsize(__qt_%1.size());\n"+
                                  "    }\n"+
                                  "}else if(%out>__qt_%1.size()){\n"+
                                  "    %out = jsize(__qt_%1.size());\n"+
                                  "}"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "QByteArray(const char*,qsizetype)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            ModifyArgument{
                index: 2
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "qsizetype %out = %in;\n"+
                                  "if(%in<0){\n"+
                                  "    if(qsizetype(qstrlen(__qt_%1))>__qt_%1.size()){\n"+
                                  "        %out = __qt_%1.size();\n"+
                                  "    }\n"+
                                  "}else if(%out>__qt_%1.size()){\n"+
                                  "    %out = __qt_%1.size();\n"+
                                  "}"}
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "append(QString)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "append(int, char)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "append(qsizetype, char)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "insert(int, int, char)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "insert(qsizetype, qsizetype, char)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "insert(qsizetype, const char*)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "insert(qsizetype, QByteArray)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "prepend(int, char)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "prepend(qsizetype, char)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "append(const char*)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
        }
        ModifyFunction{
            signature: "append(const char*,int)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            ModifyArgument{
                index: 2
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jsize %out = %in;\n"+
                                  "if(%out<0){\n"+
                                  "    if(qstrlen(__qt_%1)>__qt_%1.size()){\n"+
                                  "        %out = jsize(__qt_%1.size());\n"+
                                  "    }\n"+
                                  "}else if(%out>__qt_%1.size()){\n"+
                                  "    %out = jsize(__qt_%1.size());\n"+
                                  "}"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "append(const char*,qsizetype)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            ModifyArgument{
                index: 2
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "qsizetype %out = qsizetype(%in);\n"+
                                  "if(%in<0){\n"+
                                  "    if(qsizetype(qstrlen(__qt_%1))>__qt_%1.size()){\n"+
                                  "        %out = __qt_%1.size();\n"+
                                  "    }\n"+
                                  "}else if(%out>__qt_%1.size()){\n"+
                                  "    %out = __qt_%1.size();\n"+
                                  "}"}
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "append(QByteArray)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
        }
        ModifyFunction{
            signature: "append(QByteArrayView)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "append(char)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
        }
        ModifyFunction{
            signature: "contains(const char*)const"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "compare(const char *, Qt::CaseSensitivity) const"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            since: [5, 12]
            until: 5
        }
        ModifyFunction{
            signature: "count(const char*)const"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "endsWith(const char*)const"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "fill(char,int)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "fill(char,qsizetype)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "indexOf(const char*,int)const"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "insert(int,QByteArray)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "insert(int,char)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "insert(qsizetype,QByteArrayView)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "insert(qsizetype,char)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "insert(int,QString)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "insert(int,const char*)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "lastIndexOf(const char*,int)const"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "prepend(QByteArray)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
        }
        ModifyFunction{
            signature: "prepend(QByteArrayView)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "prepend(char)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
        }
        ModifyFunction{
            signature: "prepend(const char*)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
        }
        ModifyFunction{
            signature: "prepend(const char*, int)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            ModifyArgument{
                index: 2
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jsize %out = %in;\n"+
                                  "if(%out<0){\n"+
                                  "    if(qstrlen(__qt_%1)>__qt_%1.size()){\n"+
                                  "        %out = jsize(__qt_%1.size());\n"+
                                  "    }\n"+
                                  "}else if(%out>__qt_%1.size()){\n"+
                                  "    %out = jsize(__qt_%1.size());\n"+
                                  "}"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "prepend(const char*, qsizetype)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            ModifyArgument{
                index: 2
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "qsizetype %out = %in;\n"+
                                  "if(%in<0){\n"+
                                  "    if(qsizetype(qstrlen(__qt_%1))>__qt_%1.size()){\n"+
                                  "        %out = __qt_%1.size();\n"+
                                  "    }\n"+
                                  "}else if(%out>__qt_%1.size()){\n"+
                                  "    %out = __qt_%1.size();\n"+
                                  "}"}
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "replace(int, int, const char *, int)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            ModifyArgument{
                index: 3
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            ModifyArgument{
                index: 4
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jsize %out = %in;\n"+
                                  "if(%out<0){\n"+
                                  "    if(qstrlen(__qt_%3)>__qt_%3.size()){\n"+
                                  "        %out = jsize(__qt_%3.size());\n"+
                                  "    }\n"+
                                  "}else if(%out>__qt_%3.size()){\n"+
                                  "    %out = jsize(__qt_%3.size());\n"+
                                  "}"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "replace(qsizetype, qsizetype, const char *, qsizetype)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            ModifyArgument{
                index: 3
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            ModifyArgument{
                index: 4
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "qsizetype %out = %in;\n"+
                                  "if(%in<0){\n"+
                                  "    if(qsizetype(qstrlen(__qt_%3))>__qt_%3.size()){\n"+
                                  "        %out = __qt_%3.size();\n"+
                                  "    }\n"+
                                  "}else if(%out>__qt_%3.size()){\n"+
                                  "    %out = __qt_%3.size();\n"+
                                  "}"}
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "insert(int, const char *, int)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            ModifyArgument{
                index: 3
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jsize %out = %in;\n"+
                                  "if(%out<0){\n"+
                                  "    if(qstrlen(__qt_%2)>__qt_%2.size()){\n"+
                                  "        %out = jsize(__qt_%2.size());\n"+
                                  "    }\n"+
                                  "}else if(%out>__qt_%2.size()){\n"+
                                  "    %out = jsize(__qt_%2.size());\n"+
                                  "}"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "insert(qsizetype, const char *, qsizetype)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            ModifyArgument{
                index: 3
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "qsizetype %out = %in;\n"+
                                  "if(%in<0){\n"+
                                  "    if(qsizetype(qstrlen(__qt_%2))>__qt_%2.size()){\n"+
                                  "        %out = __qt_%2.size();\n"+
                                  "    }\n"+
                                  "}else if(%out>__qt_%2.size()){\n"+
                                  "    %out = __qt_%2.size();\n"+
                                  "}"}
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "remove(int,int)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "remove(qsizetype,qsizetype)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "replace(QByteArray,const char*)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "replace(char,QByteArray)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "replace(char,QByteArrayView)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "replace(QString,const char*)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "replace(int,int,const char*)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            ModifyArgument{
                index: 3
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "replace(const char*,const char*)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "replace(const char*,int,const char*,int)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            ModifyArgument{
                index: 2
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jsize %out = %in;\n"+
                                  "if(%out<0){\n"+
                                  "    if(qstrlen(__qt_%1)>__qt_%1.size()){\n"+
                                  "        %out = jsize(__qt_%1.size());\n"+
                                  "    }\n"+
                                  "}else if(%out>__qt_%1.size()){\n"+
                                  "    %out = jsize(__qt_%1.size());\n"+
                                  "}"}
                }
            }
            ModifyArgument{
                index: 3
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            ModifyArgument{
                index: 4
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jsize %out = %in;\n"+
                                  "if(%out<0){\n"+
                                  "    if(qstrlen(__qt_%3)>__qt_%3.size()){\n"+
                                  "        %out = jsize(__qt_%3.size());\n"+
                                  "    }\n"+
                                  "}else if(%out>__qt_%3.size()){\n"+
                                  "    %out = jsize(__qt_%3.size());\n"+
                                  "}"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "replace(const char*,qsizetype,const char*,qsizetype)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            ModifyArgument{
                index: 2
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "qsizetype %out = %in;\n"+
                                  "if(%in<0){\n"+
                                  "    if(qsizetype(qstrlen(__qt_%1))>__qt_%1.size()){\n"+
                                  "        %out = __qt_%1.size();\n"+
                                  "    }\n"+
                                  "}else if(%out>__qt_%1.size()){\n"+
                                  "    %out = __qt_%1.size();\n"+
                                  "}"}
                }
            }
            ModifyArgument{
                index: 3
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            ModifyArgument{
                index: 4
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "qsizetype %out = %in;\n"+
                                  "if(%in<0){\n"+
                                  "    if(qsizetype(qstrlen(__qt_%1))>__qt_%1.size()){\n"+
                                  "        %out = __qt_%1.size();\n"+
                                  "    }\n"+
                                  "}else if(%out>__qt_%1.size()){\n"+
                                  "    %out = __qt_%1.size();\n"+
                                  "}"}
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "replace(const char*,QByteArray)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "replace(int,int,QByteArray)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "replace(qsizetype,qsizetype,QByteArrayView)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "replace(char,const char*)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "replace(char,QString)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "replace(char,char)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
        }
        ModifyFunction{
            signature: "replace(QByteArray,QByteArray)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "replace(QByteArrayView,QByteArrayView)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "replace(QString,QByteArray)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "setNum(int,int)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
        }
        ModifyFunction{
            signature: "setNum(float,char,int)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "char"
                }
            }
        }
        ModifyFunction{
            signature: "setNum(long long,int)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
        }
        ModifyFunction{
            signature: "setNum(double,char,int)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "char"
                }
            }
        }
        ModifyFunction{
            signature: "setNum(short,int)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
        }
        ModifyFunction{
            signature: "startsWith(const char*)const"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "fromRawData(const char*,int)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            ModifyArgument{
                index: 2
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jsize %out = qMin(%in, jsize(__qt_%1.size()));"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "fromRawData(const char*,qsizetype)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            ModifyArgument{
                index: 2
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jsize %out = qMin(%in, jsize(__qt_%1.size()));"}
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "setRawData(const char*,uint)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            ModifyArgument{
                index: 2
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jsize %out = qMin(%in, jsize(__qt_%1.size()));"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "setRawData(const char*,qsizetype)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
            ModifyArgument{
                index: 2
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jsize %out = qMin(%in, jsize(__qt_%1.size()));"}
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "data() const"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.nio.ByteBuffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = %env->NewDirectByteBuffer(const_cast<char*>(%in), jlong(__qt_this->capacity()));\n"+
                                  "%out = Java::Runtime::ByteBuffer::asReadOnlyBuffer(%env, %out);"}
                }
            }
        }
        ModifyFunction{
            signature: "constData() const"
            rename: "toByteArray"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "byte[]"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = %env->NewByteArray(jsize(__qt_this->size()));\n"+
                                  "%env->SetByteArrayRegion(%out, 0, jsize(__qt_this->size()), reinterpret_cast<const jbyte *>(%in));"}
                }
            }
        }
        ModifyFunction{
            signature: "operator=(const char*)"
            rename: "set"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.nio.Buffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JBufferConstData %out(%env, %in);"}
                }
            }
        }
        ModifyFunction{
            signature: "operator<(const char*)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArrayView"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QByteArrayView %out = qtjambi_cast<QByteArrayView>(%env, %in);"}
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "operator==(const char*)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArrayView"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QByteArrayView %out = qtjambi_cast<QByteArrayView>(%env, %in);"}
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "operator=(QByteArray)"
            rename: "set"
            ModifyArgument{
                index: 0
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
            }
        }
        ModifyFunction{
            signature: "fromBase64Encoding(const QByteArray &, QFlags<QByteArray::Base64Option>)"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray$FromBase64Result"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = Java::QtCore::QByteArray$FromBase64Result::newInstance(%env, qtjambi_cast<jobject>(%env, %in.decoded), jint(%in.decodingStatus));"}
                }
            }
            since: [5, 15]
        }
        ModifyFunction{
            signature: "removeAt(qsizetype)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            since: [6,5]
        }
        ModifyFunction{
            signature: "removeFirst()"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            since: [6,5]
        }
        ModifyFunction{
            signature: "removeLast()"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            since: [6,5]
        }
    }
    
    IteratorType{
        name: "QByteArray::const_iterator"
    }

    IteratorType{
        name: "QByteArray::iterator"
        isConst: true
    }
    
    ValueType{
        name: "QTextBoundaryFinder"
        ModifyFunction{
            signature: "QTextBoundaryFinder(QTextBoundaryFinder::BoundaryType,const QChar*,int,unsigned char*,int)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "QTextBoundaryFinder(QTextBoundaryFinder::BoundaryType,const QChar*,qsizetype,unsigned char*,qsizetype)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "QTextBoundaryFinder(QTextBoundaryFinder::BoundaryType, QStringView, unsigned char *, qsizetype)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "operator=(QTextBoundaryFinder)"
            remove: RemoveFlag.All
        }
    }
    
    ValueType{
        name: "QEasingCurve"
        ModifyFunction{
            signature: "operator!=(const QEasingCurve &)const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator=(const QEasingCurve &)"
            remove: RemoveFlag.All
        }
    }
    
    FunctionalType{
        name: "QEasingCurve::EasingFunction"
    }
    
    ValueType{
        name: "QItemSelection"
        InjectCode{
            target: CodeClass.Native
            position: Position.Beginning
            Text{content: "namespace QtJambiPrivate{\n"+
                          "    template<>\n"+
                          "    struct supports_less_than<QItemSelection> : std::false_type{};\n"+
                          "    template<>\n"+
                          "    struct supports_stream_operators<QItemSelection> : std::false_type{};\n"+
                          "    template<>\n"+
                          "    struct supports_debugstream<QItemSelection> : std::false_type{};\n"+
                          "}"}
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QItemSelection___"
                quoteBeforeLine: "}// class"
            }
        }
        ModifyFunction{
            signature: "split(QItemSelectionRange,QItemSelectionRange,QItemSelection*)"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "io.qt.core.QItemSelection"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = qtjambi_cast<jobject>(%env, result);"}
                }
            }
            ModifyArgument{
                index: 3
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QItemSelection result;\n"+
                                  "QItemSelection * %out = &result;"}
                }
            }
        }
    }
    
    ValueType{
        name: "QItemSelectionRange"
        threadAffinity: "model()"
        ModifyFunction{
            signature: "operator=(QItemSelectionRange)"
            remove: RemoveFlag.All
            until: 5
        }
    }
    
    EnumType{
        name: "QItemSelectionModel::SelectionFlag"
        flags: "QItemSelectionModel::SelectionFlags"
    }
    
    ObjectType{
        name: "QItemSelectionModel"
        ModifyFunction{
            signature: "model()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "setModel(QAbstractItemModel*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    action: ReferenceCount.Ignore
                }
            }
        }
    }
    
    ObjectType{
        name: "QAbstractAnimation"
    }
    
    ObjectType{
        name: "QVariantAnimation"
    }
    
    ObjectType{
        name: "QAnimationGroup"
        ModifyFunction{
            signature: "addAnimation(QAbstractAnimation*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    action: ReferenceCount.Ignore
                }
            }
        }
        ModifyFunction{
            signature: "removeAnimation(QAbstractAnimation*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    action: ReferenceCount.Ignore
                }
            }
        }
        ModifyFunction{
            signature: "insertAnimation(int,QAbstractAnimation*)"
            ModifyArgument{
                index: 2
                ReferenceCount{
                    action: ReferenceCount.Ignore
                }
            }
        }
        ModifyFunction{
            signature: "takeAnimation(int)"
            ModifyArgument{
                index: "return"
                DefineOwnership{
                    codeClass: CodeClass.Native
                    ownership: Ownership.Java
                }
            }
        }
    }
    
    ObjectType{
        name: "QPauseAnimation"
    }
    
    ObjectType{
        name: "QParallelAnimationGroup"
    }
    
    ObjectType{
        name: "QSequentialAnimationGroup"
    }
    
    ObjectType{
        name: "QPropertyAnimation"
        ModifyFunction{
            signature: "setTargetObject(QObject*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    action: ReferenceCount.Ignore
                }
            }
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QPropertyAnimation__"
                quoteBeforeLine: "}// class"
            }
        }
    }
    
    ObjectType{
        name: "QAbstractProxyModel"
        ExtraIncludes{
            Include{
                fileName: "QItemSelection"
                location: Include.Global
            }
            Include{
                fileName: "QStringList"
                location: Include.Global
            }
            Include{
                fileName: "QSize"
                location: Include.Global
            }
        }
        ModifyFunction{
            signature: "setSourceModel(QAbstractItemModel *)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcSourceModel"
                    action: ReferenceCount.Set
                }
            }
        }
        ModifyFunction{
            signature: "createSourceIndex(int,int,void*)const"
            remove: RemoveFlag.All
            since: [6, 2]
        }
    }
    
    ObjectType{
        name: "QSortFilterProxyModel"
        ModifyFunction{
            signature: "parent()const"
            remove: RemoveFlag.All
        }
        ExtraIncludes{
            Include{
                fileName: "QItemSelection"
                location: Include.Global
            }
            Include{
                fileName: "QStringList"
                location: Include.Global
            }
            Include{
                fileName: "QSize"
                location: Include.Global
            }
        }
        ModifyFunction{
            signature: "setSourceModel(QAbstractItemModel *)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcSourceModel"
                    action: ReferenceCount.Set
                }
            }
        }
        ModifyFunction{
            signature: "clear()"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "filterChanged()"
            remove: RemoveFlag.All
            until: 5
        }
    }
    
    ObjectType{
        name: "QIdentityProxyModel"
        ExtraIncludes{
            Include{
                fileName: "QItemSelection"
                location: Include.Global
            }
            Include{
                fileName: "QStringList"
                location: Include.Global
            }
            Include{
                fileName: "QSize"
                location: Include.Global
            }
        }
        ModifyFunction{
            signature: "setSourceModel(QAbstractItemModel *)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcSourceModel"
                    action: ReferenceCount.Set
                }
            }
        }
        ModifyFunction{
            signature: "match(QModelIndex, int, QVariant, int, QFlags<Qt::MatchFlag>) const"
            ModifyArgument{
                index: 5
                RemoveDefaultExpression{
                }
            }
        }
    }
    
    ObjectType{
        name: "QAbstractState"
        ModifyFunction{
            signature: "onEntry(QEvent*)"
            ModifyArgument{
                index: 1
                invalidateAfterUse: true
            }
        }
        ModifyFunction{
            signature: "onExit(QEvent*)"
            ModifyArgument{
                index: 1
                invalidateAfterUse: true
            }
        }
        until: 5
    }
    
    EnumType{
        name: "QAbstractTransition::TransitionType"
        until: 5
    }
    
    ObjectType{
        name: "QAbstractTransition"
        ModifyFunction{
            signature: "addAnimation(QAbstractAnimation*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcAnimation"
                    action: ReferenceCount.Add
                }
            }
        }
        ModifyFunction{
            signature: "removeAnimation(QAbstractAnimation*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcAnimation"
                    action: ReferenceCount.Take
                }
            }
        }
        ModifyFunction{
            signature: "eventTest(QEvent*)"
            ModifyArgument{
                index: 1
                invalidateAfterUse: true
            }
        }
        ModifyFunction{
            signature: "onTransition(QEvent*)"
            ModifyArgument{
                index: 1
                invalidateAfterUse: true
            }
        }
        ModifyFunction{
            signature: "addAnimation(QAbstractAnimation *)"
            ppCondition: "QT_CONFIG(animation)"
        }
        ModifyFunction{
            signature: "removeAnimation(QAbstractAnimation *)"
            ppCondition: "QT_CONFIG(animation)"
        }
        ModifyFunction{
            signature: "animations() const"
            ppCondition: "QT_CONFIG(animation)"
        }
        ModifyFunction{
            signature: "setTargetState(QAbstractState*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcTargetStates"
                    action: ReferenceCount.ClearAdd
                }
            }
        }
        ModifyFunction{
            signature: "setTargetStates(const QList<QAbstractState*>&)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcTargetStates"
                    action: ReferenceCount.ClearAddAll
                }
            }
        }
        until: 5
    }
    
    ObjectType{
        name: "QState"
        ModifyFunction{
            signature: "addTransition(QAbstractTransition*)"
            ModifyArgument{
                index: 1
                NoNullPointer{
                }
                ReferenceCount{
                    action: ReferenceCount.Ignore
                }
            }
        }
        ModifyFunction{
            signature: "removeTransition(QAbstractTransition*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    action: ReferenceCount.Ignore
                }
            }
        }
        ModifyFunction{
            signature: "setErrorState(QAbstractState*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcErrorState"
                    action: ReferenceCount.Set
                }
            }
        }
        ModifyFunction{
            signature: "setInitialState(QAbstractState*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcInitialState"
                    action: ReferenceCount.Set
                }
            }
        }
        InjectCode{
            target: CodeClass.Java
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QState___"
                quoteBeforeLine: "}// class"
            }
        }
        ModifyFunction{
            signature: "addTransition(const QObject *, const char *, QAbstractState *)"
            ModifyArgument{
                index: 1
                NoNullPointer{
                }
                ReferenceCount{
                    action: ReferenceCount.Ignore
                }
            }
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
            ModifyArgument{
                index: 3
                NoNullPointer{
                }
                ReferenceCount{
                    action: ReferenceCount.Ignore
                }
            }
            InjectCode{
                target: CodeClass.Java
                position: Position.Beginning
                ArgumentMap{
                    index: 2
                    metaName: "signal"
                }
                ArgumentMap{
                    index: 1
                    metaName: "sender"
                }
                Text{content: "if(signal==null || signal.isEmpty())\n"+
                              "    return null;\n"+
                              "if(!signal.startsWith(\"2\")){\n"+
                              "    io.qt.core.QMetaMethod method = sender.metaObject().method(signal);\n"+
                              "    if(method!=null && method.methodType()==io.qt.core.QMetaMethod.MethodType.Signal) {\n"+
                              "        signal = \"2\" + method.cppMethodSignature();\n"+
                              "    }\n"+
                              "}"}
            }
            InjectCode{
                target: CodeClass.Java
                position: Position.End
                ArgumentMap{
                    index: 0
                    metaName: "%0"
                }
                ArgumentMap{
                    index: 3
                    metaName: "%3"
                }
                Text{content: "QtJambi_LibraryUtilities.internal.addReferenceCount(%0, QAbstractTransition.class, \"__rcTargetStates\", false, false, %3);"}
            }
        }
        ModifyFunction{
            signature: "addTransition(QAbstractState*)"
            ModifyArgument{
                index: 1
                NoNullPointer{
                }
                ReferenceCount{
                    action: ReferenceCount.Ignore
                }
            }
            InjectCode{
                target: CodeClass.Java
                position: Position.End
                ArgumentMap{
                    index: 0
                    metaName: "%0"
                }
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                Text{content: "QtJambi_LibraryUtilities.internal.addReferenceCount(%0, QAbstractTransition.class, \"__rcTargetStates\", false, false, %1);"}
            }
        }
        ModifyFunction{
            signature: "assignProperty(QObject *, const char *, const QVariant &)"
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        InjectCode{
            target: CodeClass.Java
        }
        until: 5
    }
    
    ObjectType{
        name: "QStateMachine"
        ModifyFunction{
            signature: "beginMicrostep(QEvent*)"
            ModifyArgument{
                index: 1
                invalidateAfterUse: true
            }
        }
        ModifyFunction{
            signature: "beginSelectTransitions(QEvent*)"
            ModifyArgument{
                index: 1
                invalidateAfterUse: true
            }
        }
        ModifyFunction{
            signature: "endMicrostep(QEvent*)"
            ModifyArgument{
                index: 1
                invalidateAfterUse: true
            }
        }
        ModifyFunction{
            signature: "endSelectTransitions(QEvent*)"
            ModifyArgument{
                index: 1
                invalidateAfterUse: true
            }
        }
        ModifyFunction{
            signature: "addDefaultAnimation(QAbstractAnimation*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcDefaultAnimations"
                    action: ReferenceCount.Add
                }
            }
        }
        ModifyFunction{
            signature: "removeDefaultAnimation(QAbstractAnimation*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcDefaultAnimations"
                    action: ReferenceCount.Take
                }
            }
        }
        ModifyFunction{
            signature: "addState(QAbstractState*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcStates"
                    action: ReferenceCount.Add
                }
            }
        }
        ModifyFunction{
            signature: "removeState(QAbstractState*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcStates"
                    action: ReferenceCount.Take
                }
            }
        }
        ModifyFunction{
            signature: "eventFilter(QObject*,QEvent*)"
            ModifyArgument{
                index: 2
                invalidateAfterUse: true
            }
        }
        until: 5
    }
    
    ObjectType{
        name: "QHistoryState"
        ModifyFunction{
            signature: "setDefaultTransition(QAbstractTransition*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    action: ReferenceCount.Ignore
                }
            }
        }
        ModifyFunction{
            signature: "setDefaultState(QAbstractState*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    action: ReferenceCount.Ignore
                }
            }
            InjectCode{
                target: CodeClass.Java
                position: Position.End
                ArgumentMap{
                    index: 0
                    metaName: "%0"
                }
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                Text{content: "QtJambi_LibraryUtilities.internal.addReferenceCount(defaultTransition(), QAbstractTransition.class, \"__rcTargetStates\", false, false, %1);"}
            }
        }
        until: 5
    }
    
    ObjectType{
        name: "QSignalTransition"
        ModifyFunction{
            signature: "setSenderObject(const QObject*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcSenderObject"
                    action: ReferenceCount.Set
                }
            }
        }
        InjectCode{
            target: CodeClass.Java
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QSignalTransition___"
                quoteBeforeLine: "}// class"
            }
        }
        ModifyFunction{
            signature: "QSignalTransition(const QObject *, const char *, QState *)"
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
            InjectCode{
                target: CodeClass.Java
                position: Position.Beginning
                ArgumentMap{
                    index: 2
                    metaName: "signal"
                }
                ArgumentMap{
                    index: 1
                    metaName: "sender"
                }
                Text{content: "if(signal!=null && !signal.startsWith(\"2\")){\n"+
                              "    io.qt.core.QMetaMethod method = sender.metaObject().method(signal);\n"+
                              "    if(method!=null && method.methodType()==io.qt.core.QMetaMethod.MethodType.Signal) {\n"+
                              "        signal = \"2\" + method.cppMethodSignature();\n"+
                              "    }\n"+
                              "}"}
            }
        }
        ModifyFunction{
            signature: "setSignal(const QByteArray &)"
            InjectCode{
                target: CodeClass.Java
                position: Position.Beginning
                ArgumentMap{
                    index: 1
                    metaName: "signal"
                }
                Text{content: "if(signal!=null && !signal.startsWith(\"2\")){\n"+
                              "    io.qt.core.QMetaMethod method = senderObject().metaObject().method(signal.toString());\n"+
                              "    if(method!=null && method.methodType()==io.qt.core.QMetaMethod.MethodType.Signal) {\n"+
                              "        signal = new io.qt.core.QByteArray(\"2\");\n"+
                              "        signal.append(method.cppMethodSignature());\n"+
                              "    }\n"+
                              "}"}
            }
        }
        until: 5
    }
    
    ObjectType{
        name: "QEventTransition"
        ModifyFunction{
            signature: "setEventSource(QObject*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcEventSource"
                    action: ReferenceCount.Set
                }
            }
        }
        until: 5
    }
    
    ObjectType{
        name: "QFinalState"
        until: 5
    }
    
    ValueType{
        name: "QMargins"
        ModifyFunction{
            signature: "operator-=(int)"
            rename: "subtract"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QMargins"
                }
            }
        }
        ModifyFunction{
            signature: "operator+=(int)"
            rename: "add"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QMargins"
                }
            }
        }
        ModifyFunction{
            signature: "operator*=(int)"
            rename: "multiply"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QMargins"
                }
            }
        }
        ModifyFunction{
            signature: "operator/=(int)"
            rename: "divide"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QMargins"
                }
            }
        }
        ModifyFunction{
            signature: "operator*=(qreal)"
            rename: "multiply"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QMargins"
                }
            }
        }
        ModifyFunction{
            signature: "operator/=(qreal)"
            rename: "divide"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QMargins"
                }
            }
        }
        ModifyFunction{
            signature: "operator-=(const QMargins &)"
            rename: "subtract"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QMargins"
                }
            }
        }
        ModifyFunction{
            signature: "operator+=(const QMargins &)"
            rename: "add"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QMargins"
                }
            }
        }
    }
    
    ValueType{
        name: "QMarginsF"
        ModifyFunction{
            signature: "operator-=(qreal)"
            rename: "subtract"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QMarginsF"
                }
            }
        }
        ModifyFunction{
            signature: "operator+=(qreal)"
            rename: "add"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QMarginsF"
                }
            }
        }
        ModifyFunction{
            signature: "operator*=(qreal)"
            rename: "multiply"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QMarginsF"
                }
            }
        }
        ModifyFunction{
            signature: "operator/=(qreal)"
            rename: "divide"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QMarginsF"
                }
            }
        }
        ModifyFunction{
            signature: "operator-=(const QMarginsF &)"
            rename: "subtract"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QMarginsF"
                }
            }
        }
        ModifyFunction{
            signature: "operator+=(const QMarginsF &)"
            rename: "add"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QMarginsF"
                }
            }
        }
    }
    
    ObjectType{
        name: "QXmlStreamEntityResolver"
    }
    
    ObjectType{
        name: "QAbstractEventDispatcher"
        ModifyFunction{
            signature: "instance(QThread*)"
            ModifyArgument{
                index: 0
                DefineOwnership{
                    codeClass: CodeClass.Native
                    ownership: Ownership.Cpp
                }
            }
        }
        InjectCode{
            target: CodeClass.ShellDeclaration
            position: Position.End
            Text{content: "#if defined(Q_OS_WIN) && QT_VERSION < QT_VERSION_CHECK(6,0,0)\n"+
                          "public:\n"+
                          "    inline bool registerEventNotifier(QWinEventNotifier *) override {return false;}\n"+
                          "    inline void unregisterEventNotifier(QWinEventNotifier *) override {}\n"+
                          "#endif"}
        }
        ModifyFunction{
            signature: "interrupt()"
            threadAffinity: false
        }
        ModifyFunction{
            signature: "wakeUp()"
            threadAffinity: false
        }
        ModifyFunction{
            signature: "registerSocketNotifier(QSocketNotifier *)"
            threadAffinity: true
            ModifyArgument{
                index: 1
                threadAffinity: true
                NoNullPointer{
                }
                ReferenceCount{
                    variableName: "__rcSocketNotifier"
                    action: ReferenceCount.Add
                }
            }
        }
        ModifyFunction{
            signature: "unregisterSocketNotifier(QSocketNotifier *)"
            threadAffinity: true
            ModifyArgument{
                index: 1
                threadAffinity: true
                NoNullPointer{
                }
                ReferenceCount{
                    variableName: "__rcSocketNotifier"
                    action: ReferenceCount.Take
                }
            }
        }
        ModifyFunction{
            signature: "unregisterTimer(int)"
            threadAffinity: true
        }
        ModifyFunction{
            signature: "unregisterTimers(QObject*)"
            threadAffinity: true
            ModifyArgument{
                index: 1
                threadAffinity: true
            }
        }
        ModifyFunction{
            signature: "registerTimer(int, Qt::TimerType, QObject*)"
            threadAffinity: true
            ModifyArgument{
                index: 3
                threadAffinity: true
            }
            InjectCode{
                target: CodeClass.Java
                position: Position.Beginning
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                Text{content: "if(%1 < 0){\n"+
                              "    throw new IllegalArgumentException(\"Timers cannot have negative intervals.\");\n"+
                              "}"}
            }
            until: 5
        }
        ModifyFunction{
            signature: "registerTimer(long long, Qt::TimerType, QObject*)"
            threadAffinity: true
            ModifyArgument{
                index: 3
                threadAffinity: true
            }
            InjectCode{
                target: CodeClass.Java
                position: Position.Beginning
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                Text{content: "if(%1 < 0){\n"+
                              "    throw new IllegalArgumentException(\"Timers cannot have negative intervals.\");\n"+
                              "}"}
            }
            since: 6
        }
        ModifyFunction{
            signature: "registerTimer(int, int, Qt::TimerType, QObject*)"
            threadAffinity: true
            ModifyArgument{
                index: 4
                threadAffinity: true
            }
            InjectCode{
                target: CodeClass.Java
                position: Position.Beginning
                ArgumentMap{
                    index: 2
                    metaName: "%2"
                }
                Text{content: "if(%2 < 0){\n"+
                              "    throw new IllegalArgumentException(\"Timers cannot have negative intervals.\");\n"+
                              "}"}
            }
            until: 5
        }
        ModifyFunction{
            signature: "registerTimer(int, long long, Qt::TimerType, QObject*)"
            threadAffinity: true
            ModifyArgument{
                index: 4
                threadAffinity: true
            }
            InjectCode{
                target: CodeClass.Java
                position: Position.Beginning
                ArgumentMap{
                    index: 2
                    metaName: "%2"
                }
                Text{content: "if(%2 < 0){\n"+
                              "    throw new IllegalArgumentException(\"Timers cannot have negative intervals.\");\n"+
                              "}"}
            }
            since: 6
        }
    }
    
    ValueType{
        name: "QAbstractEventDispatcher::TimerInfo"
        CustomConstructor{
            Text{content: "if(copy){\n"+
                          "    return new(placement) QAbstractEventDispatcher::TimerInfo(copy->timerId, copy->interval, copy->timerType);\n"+
                          "}else{\n"+
                          "    return new(placement) QAbstractEventDispatcher::TimerInfo(0, 0, Qt::PreciseTimer);\n"+
                          "}"}
        }
        CustomConstructor{
            type: CustomConstructor.Default
            Text{content: "new(placement) QAbstractEventDispatcher::TimerInfo(0, 0, Qt::PreciseTimer);"}
        }
        CustomConstructor{
            type: CustomConstructor.Copy
            Text{content: "new(placement) QAbstractEventDispatcher::TimerInfo(copy->timerId, copy->interval, copy->timerType);"}
        }
    }
    
    EnumType{
        name: "QVersionNumber::SegmentStorage"
    }
    
    ValueType{
        name: "QVersionNumber"
        CustomConstructor{
            Text{content: "if(copy){\n"+
                          "    return new(placement) QVersionNumber(copy->majorVersion(), copy->minorVersion(), copy->microVersion());\n"+
                          "}else{\n"+
                          "    return new(placement) QVersionNumber();\n"+
                          "}"}
        }
        CustomConstructor{
            type: CustomConstructor.Copy
            until: [6, 0]
            Text{content: "new(placement) QVersionNumber(copy->majorVersion(), copy->minorVersion(), copy->microVersion());"}
        }
        CustomConstructor{
            type: CustomConstructor.Copy
            since: [6, 1]
            Text{content: "new(placement) QVersionNumber(copy->segments());"}
        }
        ModifyFunction{
            signature: "fromString(QLatin1String, int *)"
            remove: RemoveFlag.All
            since: [5, 10]
            until: [6, 3]
        }
        ModifyFunction{
            signature: "fromString(QStringView, int *)"
            remove: RemoveFlag.All
            since: [5, 10]
            until: [6, 3]
        }
        ModifyFunction{
            signature: "fromString(const QString &, int *)"
            ModifyArgument{
                index: 2
                ArrayType{
                    minLength: 1
                }
            }
            since: [5, 10]
            until: [6, 3]
        }
        ModifyFunction{
            signature: "fromString(QAnyStringView, qsizetype *)"
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "int[]"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "qsizetype* %out;\n"+
                                  "if constexpr(sizeof(int)==sizeof(qsizetype)){\n"+
                                  "    %out = qtjambi_array_cast<qsizetype*>(%env, %scope, %in, 1);\n"+
                                  "}else{\n"+
                                  "    if(int* tmp = qtjambi_array_cast<int*>(%env, %scope, %in, 1)){\n"+
                                  "        %out = new qsizetype(*tmp);\n"+
                                  "        %scope.addFinalAction([=]{*tmp = jint(*%out); delete %out;});\n"+
                                  "    }else{\n"+
                                  "        %out = nullptr;\n"+
                                  "    }\n"+
                                  "}"}
                }
            }
            since: [6, 4]
        }
    }
    
    ObjectType{
        name: "QEventLoop"
        ModifyFunction{
            signature: "wakeUp()"
            threadAffinity: false
        }
    }
    
    ObjectType{
        name: "QFile"
        ModifyFunction{
            signature: "readLink()const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "readLink(QString)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "rename(const QString &)"
            access: Modification.NonFinal
            since: [5, 10]
        }
        ExtraIncludes{
            Include{
                fileName: "utils_p.h"
                location: Include.Local
            }
        }
        ModifyFunction{
            signature: "decodeName(const char*)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        ModifyFunction{
            signature: "moveToTrash(const QString &, QString *)"
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QString %in;\n"+
                                  "QString* %out = &%in;"}
                }
            }
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "io.qt.core.QFile$TrashResult"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = Java::QtCore::QFile$TrashResult::newInstance(%env, jboolean(%in), qtjambi_cast<jstring>(%env, %2));"}
                }
            }
            since: [5, 15]
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QFile__"
                quoteBeforeLine: "}// class"
                since: [5, 15]
            }
        }
    }
    
    ObjectType{
        name: "QFileDevice"
        ExtraIncludes{
            Include{
                fileName: "QtJambi/JavaAPI"
                location: Include.Global
            }
        }
        ModifyFunction{
            signature: "map(long long, long long, QFileDevice::MemoryMapFlags)"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.nio.ByteBuffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = %in ? %env->NewDirectByteBuffer(%in, qMin(%2, jlong(__qt_this->size())-%1)) : nullptr;"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "map(long long, long long, QFlags<QFileDevice::MemoryMapFlag>)"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.nio.ByteBuffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = %in ? %env->NewDirectByteBuffer(%in, qMin(%2, jlong(__qt_this->size())-%1)) : nullptr;"}
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "unmap(unsigned char*)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.nio.ByteBuffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "if(!Java::Runtime::Buffer::isDirect(%env,%in)){\n"+
                                  "    JavaException::raiseIllegalArgumentException(%env, \"Direct buffer expected but given buffer is indirect.\" QTJAMBI_STACKTRACEINFO );\n"+
                                  "}\n"+
                                  "uchar* %out = %in ? reinterpret_cast<uchar*>(%env->GetDirectBufferAddress(%in)) : nullptr;"}
                }
            }
        }
    }
    
    InterfaceType{
        name: "QIODeviceBase"
        noImpl: true
        ModifyFunction{
            signature: "QIODeviceBase()"
            remove: RemoveFlag.All
        }
        since: 6
    }
    
    ObjectType{
        name: "QIODevice"
        ExtraIncludes{
            Include{
                fileName: "QtJambi/JavaAPI"
                location: Include.Global
            }
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QIODevice_prefix__"
                quoteBeforeLine: "}// QIODevice_prefix__"
            }
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QIODevice_6_1__"
                quoteBeforeLine: "}// QIODevice_6_1__"
                since: 6
            }
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QIODevice_infix__"
                quoteBeforeLine: "}// QIODevice_infix__"
            }
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QIODevice_6_2__"
                quoteBeforeLine: "}// QIODevice_6_2__"
                since: 6
            }
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QIODevice_suffix__"
                quoteBeforeLine: "}// class"
            }
        }
        ModifyFunction{
            signature: "putChar(char)"
            rename: "putByte"
        }
        ModifyFunction{
            signature: "ungetChar(char)"
            rename: "ungetByte"
        }
        ModifyFunction{
            signature: "getChar(char*)"
            rename: "getByte"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.lang.Byte"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = %in ? qtjambi_cast<jobject>(%env, c) : nullptr;"}
                }
            }
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "char c(0);\n"+
                                  "char * %out = &c;"}
                }
            }
        }
        ModifyFunction{
            signature: "write(const char*)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "peek(char*,long long)"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "int"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "qint64 %out = qint64(%in);\n"+
                                  "while(%2 > INT_MAX && %in == INT_MAX){\n"+
                                  "    %2 -= INT_MAX;\n"+
                                  "    %1 = &%1[INT_MAX];\n"+
                                  "    CharPointerArray %1_buffer2(%env, %1, jsize(qMin(qint64(INT_MAX), %2)));\n"+
                                  "    %in = %env->CallIntMethod(__java_this, method_id, %1_buffer2.array());\n"+
                                  "    %out += %in;\n"+
                                  "}"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = jint(%in);"}
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "byte[]"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "jbyteArray %out = qtjambi_array_cast<jbyteArray>(%env, %scope, %in, jsize(qMin(qint64(INT_MAX), %2)));"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jsize %2 = 0;\n"+
                                  "char * %out = qtjambi_array_cast<char *>(%env, %scope, jbyteArray(%in), %2);"}
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
            }
        }
        ModifyFunction{
            signature: "read(char*,long long)"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "int"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "qint64 %out = qint64(%in);\n"+
                                  "while(%2 > INT_MAX && %in == INT_MAX){\n"+
                                  "    %2 -= INT_MAX;\n"+
                                  "    %1 = &%1[INT_MAX];\n"+
                                  "    CharPointerArray %1_buffer2(%env, %1, jsize(qMin(qint64(INT_MAX), %2)));\n"+
                                  "    %in = %env->CallIntMethod(__java_this, method_id, %1_buffer2.array());\n"+
                                  "    %out += %in;\n"+
                                  "}"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = jint(%in);"}
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "byte[]"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "jbyteArray %out = qtjambi_array_cast<jbyteArray>(%env, %scope, %in, jsize(qMin(qint64(INT_MAX), %2)));"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jsize %2 = 0;\n"+
                                  "char * %out = qtjambi_array_cast<char *>(%env, %scope, jbyteArray(%in), %2);"}
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
            }
        }
        ModifyFunction{
            signature: "readLine(char*,long long)"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "int"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "qint64 %out = qint64(%in);\n"+
                                  "while(%2 > INT_MAX && %in == INT_MAX){\n"+
                                  "    %2 -= INT_MAX;\n"+
                                  "    %1 = &%1[INT_MAX];\n"+
                                  "    CharPointerArray %1_buffer2(%env, %1, jsize(qMin(qint64(INT_MAX), %2)));\n"+
                                  "    %in = %env->CallIntMethod(__java_this, method_id, %1_buffer2.array());\n"+
                                  "    %out += %in;\n"+
                                  "}"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = jint(%in);"}
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "byte[]"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "jbyteArray %out = qtjambi_array_cast<jbyteArray>(%env, %scope, %in, jsize(qMin(qint64(INT_MAX), %2)));"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jsize %2 = 0;\n"+
                                  "char * %out = qtjambi_array_cast<char *>(%env, %scope, jbyteArray(%in), %2);"}
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
            }
        }
        ModifyFunction{
            signature: "write(const char*,long long)"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "int"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "qint64 %out = qint64(%in);\n"+
                                  "while(%2 > INT_MAX && %in == INT_MAX){\n"+
                                  "    %2 -= INT_MAX;\n"+
                                  "    %1 = &%1[INT_MAX];\n"+
                                  "    j%2 = jsize(qMin(qint64(INT_MAX), %2));\n"+
                                  "    ConstCharPointerArray __%1(%env, %1, j%2);\n"+
                                  "    %in = %env->CallIntMethod(__java_this, method_id, __%1.array());\n"+
                                  "    %out += %in;\n"+
                                  "}"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = jint(%in);"}
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "byte[]"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "jsize j%2 = jsize(qMin(qint64(INT_MAX), %2));\n"+
                                  "jbyteArray %out = qtjambi_array_cast<jbyteArray>(%env, %scope, %in, j%2);"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jsize %2 = 0;\n"+
                                  "char * %out = qtjambi_array_cast<char *>(%env, %scope, jbyteArray(%in), %2);"}
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
            }
        }
        ModifyFunction{
            signature: "readData(char*,long long)"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "int"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "qint64 %out = qint64(%in);\n"+
                                  "while(%2 > INT_MAX && %in == INT_MAX){\n"+
                                  "    %2 -= INT_MAX;\n"+
                                  "    %1 = &%1[INT_MAX];\n"+
                                  "    CharPointerArray %1_buffer2(%env, %1, jsize(qMin(qint64(INT_MAX), %2)));\n"+
                                  "    %in = %env->CallIntMethod(__java_this, method_id, %1_buffer2.array());\n"+
                                  "    %out += %in;\n"+
                                  "}"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jint %out = jint(%in);"}
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "byte[]"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "jbyteArray %out = qtjambi_array_cast<jbyteArray>(%env, %scope, %in, jsize(qMin(qint64(INT_MAX), %2)));"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jsize %2 = 0;\n"+
                                  "char * %out = qtjambi_array_cast<char *>(%env, %scope, jbyteArray(%in), %2);"}
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
            }
        }
        ModifyFunction{
            signature: "writeData(const char*,long long)"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "int"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "qint64 %out = qint64(%in);\n"+
                                  "while(%2 > INT_MAX && %in == INT_MAX){\n"+
                                  "    %2 -= INT_MAX;\n"+
                                  "    %1 = &%1[INT_MAX];\n"+
                                  "    j%2 = jsize(qMin(qint64(INT_MAX), %2));\n"+
                                  "    ConstCharPointerArray __%1(%env, %1, j%2);\n"+
                                  "    %in = %env->CallIntMethod(__java_this, method_id, __%1.array());\n"+
                                  "    %out += %in;\n"+
                                  "}"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jint %out = jint(%in);"}
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "byte[]"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "jsize j%2 = jsize(qMin(qint64(INT_MAX), %2));\n"+
                                  "jbyteArray %out = qtjambi_array_cast<jbyteArray>(%env, %scope, %in, j%2);"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jsize %2 = 0;\n"+
                                  "char * %out = qtjambi_array_cast<char *>(%env, %scope, jbyteArray(%in), %2);"}
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
            }
        }
        ModifyFunction{
            signature: "readLineData(char*,long long)"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "int"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "qint64 %out = qint64(%in);\n"+
                                  "while(%2 > INT_MAX && %in == INT_MAX){\n"+
                                  "    %2 -= INT_MAX;\n"+
                                  "    %1 = &%1[INT_MAX];\n"+
                                  "    CharPointerArray %1_buffer2(%env, %1, jsize(qMin(qint64(INT_MAX), %2)));\n"+
                                  "    %in = %env->CallIntMethod(__java_this, method_id, %1_buffer2.array());\n"+
                                  "    %out += %in;\n"+
                                  "}"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jint %out = jint(%in);"}
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "byte[]"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "jbyteArray %out = qtjambi_array_cast<jbyteArray>(%env, %scope, %in, jsize(qMin(qint64(INT_MAX), %2)));"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jsize %2 = 0;\n"+
                                  "char * %out = qtjambi_array_cast<char *>(%env, %scope, jbyteArray(%in), %2);"}
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
            }
        }
    }
    
    ObjectType{
        name: "QStateMachine::SignalEvent"
        until: 5
    }
    
    ObjectType{
        name: "QStateMachine::WrappedEvent"
        until: 5
    }
    
    ObjectType{
        name: "QCryptographicHash"
        ModifyFunction{
            signature: "addData(QIODevice*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    action: ReferenceCount.Ignore
                }
            }
        }
        ModifyFunction{
            signature: "addData(const char*,int)"
            ModifyArgument{
                index: 1
                NoNullPointer{
                }
                ArrayType{
                    lengthParameter: 2
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "addData(const char*,qsizetype)"
            ModifyArgument{
                index: 1
                NoNullPointer{
                }
                ArrayType{
                    lengthParameter: 2
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
            }
            since: 6
        }
        InjectCode{
            since: [6, 3]
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QCryptographicHash___"
                quoteBeforeLine: "}// class"
            }
        }
    }
    
    ObjectType{
        name: "QSocketNotifier"
        ModifyFunction{
            signature: "setEnabled(bool)"
            threadAffinity: true
        }
        ModifyFunction{
            signature: "setEnabled(bool)"
            threadAffinity: true
        }
    }
    
    ObjectType{
        name: "QTemporaryFile"
        ModifyFunction{
            signature: "fileName()const"
            rename: "uniqueFilename"
        }
        ModifyFunction{
            signature: "createLocalFile(QFile &)"
            ModifyArgument{
                index: "return"
                DefineOwnership{
                    codeClass: CodeClass.Native
                    ownership: Ownership.Java
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "createLocalFile(const QString &)"
            ModifyArgument{
                index: "return"
                DefineOwnership{
                    codeClass: CodeClass.Native
                    ownership: Ownership.Java
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "createNativeFile(QFile &)"
            ModifyArgument{
                index: "return"
                DefineOwnership{
                    codeClass: CodeClass.Native
                    ownership: Ownership.Java
                }
            }
        }
        ModifyFunction{
            signature: "createNativeFile(const QString &)"
            ModifyArgument{
                index: "return"
                DefineOwnership{
                    codeClass: CodeClass.Native
                    ownership: Ownership.Java
                }
            }
        }
    }
    
    ObjectType{
        name: "QTemporaryDir"
    }
    
    ObjectType{
        name: "QMimeData"
        ExtraIncludes{
            Include{
                fileName: "QStringList"
                location: Include.Global
            }
            Include{
                fileName: "QUrl"
                location: Include.Global
            }
        }
    }
    
    ObjectType{
        name: "QStringConverterBase::State"
        since: 6
    }
    
    ObjectType{
        name: "QStringConverterBase"
        ModifyFunction{
            signature: "QStringConverterBase()"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        since: 6
    }
    
    ObjectType{
        name: "QStringConverter"
        ModifyField{
            name: "state"
            read: true
            write: false
        }
        ModifyFunction{
            signature: "name() const"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        ModifyFunction{
            signature: "QStringConverter(const char *, QFlags<QStringConverterBase::Flag>)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        ModifyFunction{
            signature: "encodingForName(const char *)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        ModifyFunction{
            signature: "nameForEncoding(QStringConverter::Encoding)"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        InjectCode{
            since: 6
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QStringConverter___"
                quoteBeforeLine: "}// class"
            }
        }
        since: 6
    }
    
    EnumType{
        name: "QStringConverter::Encoding"
        RejectEnumValue{
            name: "LastEncoding"
        }
        since: 6
    }
    
    
    ObjectType{
        name: "QTextCodec"
        ModifyFunction{
            signature: "setCodecForLocale(QTextCodec*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcCodecForLocale"
                    action: ReferenceCount.Set
                }
            }
        }
        ModifyFunction{
            signature: "QTextCodec()"
            ModifyArgument{
                index: -1
                DefineOwnership{
                    codeClass: CodeClass.Native
                    ownership: Ownership.Cpp
                }
            }
        }
        ModifyFunction{
            signature: "toUnicode(const char*)const"
            Remove{
            }
        }
        ModifyFunction{
            signature: "fromUnicode(QStringView) const"
            remove: RemoveFlag.All
            since: [5, 10]
        }
        ModifyFunction{
            signature: "canEncode(QStringView) const"
            remove: RemoveFlag.All
            since: [5, 10]
        }
        ModifyFunction{
            signature: "convertFromUnicode(const QChar*,int,QTextCodec::ConverterState*)const"
            ModifyArgument{
                index: 0
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "delete[] __qt_charbuffer;\n"+
                                  "const QByteArray&  %out = qtjambi_cast<QByteArray>(%env, %in);"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jobject %out = qtjambi_cast<jobject>(%env, %in);\n"+
                                  "%env->ReleaseCharArrayElements(jcharArray(%1), reinterpret_cast<jchar *>(__qt_%1_tmp), 0);\n"+
                                  "delete[] __qt_%1;"}
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "char[]"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "// Convert directly QChar * -> ushort *\n"+
                                  "jsize __length = jsize(%2);\n"+
                                  "jcharArray %out = %env->NewCharArray(__length);\n"+
                                  "jchar* __qt_charbuffer = new jchar[size_t(%2)];\n"+
                                  "for(int i=0; i<__length; ++i){\n"+
                                  "    __qt_charbuffer[i] = jchar(%in[i].unicode());\n"+
                                  "}\n"+
                                  "%env->SetCharArrayRegion(%out, 0, __length, __qt_charbuffer);"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "// Convert directly ushort * -> QChar *\n"+
                                  "jchar *__qt_%1_tmp = %env->GetCharArrayElements(%in, nullptr);\n"+
                                  "jsize %2 = %env->GetArrayLength(%in);\n"+
                                  "QChar* %out = new QChar[size_t(%2)];\n"+
                                  "for(int i=0; i<%2; ++i){\n"+
                                  "    %out[i] = QChar(__qt_%1_tmp[i]);\n"+
                                  "}"}
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
            }
            ModifyArgument{
                index: 3
                invalidateAfterUse: true
            }
            until: 5
        }
        ModifyFunction{
            signature: "convertToUnicode(const char*,int,QTextCodec::ConverterState*)const"
            ModifyArgument{
                index: 0
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jstring %out = qtjambi_cast<jstring>(%env, %in);"}
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "byte[]"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "ConstCharPointerArray _%in(%env, %in, jsize(%2));\n"+
                                  "jbyteArray %out = _%in;"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JByteArrayPointer %out(%env, jbyteArray(%in));"}
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "// nothing"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "int %out = __qt_%1.size();"}
                }
            }
            ModifyArgument{
                index: 3
                invalidateAfterUse: true
            }
            until: 5
        }
        ModifyFunction{
            signature: "fromUnicode(const QChar*,int,QTextCodec::ConverterState*)const"
            ModifyArgument{
                index: 0
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "delete[] __qt_charbuffer;\n"+
                                  "const QByteArray&  %out = qtjambi_cast<QByteArray>(%env, %in);"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = qtjambi_cast<jobject>(%env, %in);\n"+
                                  "%env->ReleaseCharArrayElements(%1, reinterpret_cast<jchar *>(__qt_%1_tmp), 0);\n"+
                                  "delete[] __qt_%1;"}
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "char[]"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "// Convert directly QChar * -> ushort *\n"+
                                  "jsize __length = jsize(%2);\n"+
                                  "jcharArray %out = %env->NewCharArray(__length);\n"+
                                  "jchar* __qt_charbuffer = new jchar[size_t(%2)];\n"+
                                  "for(int i=0; i<__length; ++i){\n"+
                                  "    __qt_charbuffer[i] = jchar(%in[i].unicode());\n"+
                                  "}\n"+
                                  "%env->SetCharArrayRegion(%out, 0, __length, __qt_charbuffer);"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "// Convert directly ushort * -> QChar *\n"+
                                  "jchar *__qt_%1_tmp = %env->GetCharArrayElements(%in, nullptr);\n"+
                                  "jsize %2 = %env->GetArrayLength(%in);\n"+
                                  "QChar* %out = new QChar[size_t(%2)];\n"+
                                  "for(int i=0; i<%2; ++i){\n"+
                                  "    %out[i] = QChar(__qt_%1_tmp[i]);\n"+
                                  "}"}
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
            }
            ModifyArgument{
                index: 3
                invalidateAfterUse: true
            }
            until: 5
        }
        ModifyFunction{
            signature: "toUnicode(const char*,int,QTextCodec::ConverterState*)const"
            ModifyArgument{
                index: 0
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = qtjambi_cast<jstring>(%env, %in);"}
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "byte[]"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "ConstCharPointerArray _%in(%env, %in, jsize(%2));\n"+
                                  "jbyteArray %out = _%in;"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JByteArrayPointer %out(%env, jbyteArray(%in));"}
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "// nothing"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "int %out = __qt_%1.size();"}
                }
            }
            ModifyArgument{
                index: 3
                invalidateAfterUse: true
            }
            until: 5
        }
        ModifyFunction{
            signature: "convertFromUnicode(const QChar*,int,QStringConverterBase::State*)const"
            ModifyArgument{
                index: 0
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "delete[] __qt_charbuffer;\n"+
                                  "const QByteArray&  %out = qtjambi_cast<QByteArray>(%env, %in);"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = qtjambi_cast<jobject>(%env, %in);\n"+
                                  "%env->ReleaseCharArrayElements(jcharArray(%1), reinterpret_cast<jchar *>(__qt_%1_tmp), 0);\n"+
                                  "delete[] __qt_%1;"}
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "char[]"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "// Convert directly QChar * -> ushort *\n"+
                                  "jsize __length = jsize(%2);\n"+
                                  "jcharArray %out = %env->NewCharArray(__length);\n"+
                                  "jchar* __qt_charbuffer = new jchar[size_t(%2)];\n"+
                                  "for(int i=0; i<__length; ++i){\n"+
                                  "    __qt_charbuffer[i] = jchar(%in[i].unicode());\n"+
                                  "}\n"+
                                  "%env->SetCharArrayRegion(%out, 0, __length, __qt_charbuffer);"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "// Convert directly ushort * -> QChar *\n"+
                                  "jchar *__qt_%1_tmp = %env->GetCharArrayElements(%in, nullptr);\n"+
                                  "jsize %2 = %env->GetArrayLength(%in);\n"+
                                  "QChar* %out = new QChar[size_t(%2)];\n"+
                                  "for(int i=0; i<%2; ++i){\n"+
                                  "    %out[i] = QChar(__qt_%1_tmp[i]);\n"+
                                  "}"}
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
            }
            ModifyArgument{
                index: 3
                invalidateAfterUse: true
            }
            since: 6
        }
        ModifyFunction{
            signature: "convertToUnicode(const char*,int,QStringConverterBase::State*)const"
            ModifyArgument{
                index: 0
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = qtjambi_cast<jstring>(%env, %in);"}
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "byte[]"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "ConstCharPointerArray _%in(%env, %in, jsize(%2));\n"+
                                  "jbyteArray %out = _%in;"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JByteArrayPointer %out(%env, jbyteArray(%in));"}
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "// nothing"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "int %out = __qt_%1.size();"}
                }
            }
            ModifyArgument{
                index: 3
                invalidateAfterUse: true
            }
            since: 6
        }
        ModifyFunction{
            signature: "fromUnicode(const QChar*,int,QStringConverterBase::State*)const"
            ModifyArgument{
                index: 0
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "delete[] __qt_charbuffer;\n"+
                                  "const QByteArray&  %out = qtjambi_cast<QByteArray>(%env, %in);"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = qtjambi_cast<jobject>(%env, %in);\n"+
                                  "%env->ReleaseCharArrayElements(%1, reinterpret_cast<jchar *>(__qt_%1_tmp), 0);\n"+
                                  "delete[] __qt_%1;"}
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "char[]"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "// Convert directly QChar * -> ushort *\n"+
                                  "jsize __length = jsize(%2);\n"+
                                  "jcharArray %out = %env->NewCharArray(__length);\n"+
                                  "jchar* __qt_charbuffer = new jchar[size_t(%2)];\n"+
                                  "for(int i=0; i<__length; ++i){\n"+
                                  "    __qt_charbuffer[i] = jchar(%in[i].unicode());\n"+
                                  "}\n"+
                                  "%env->SetCharArrayRegion(%out, 0, __length, __qt_charbuffer);"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "// Convert directly ushort * -> QChar *\n"+
                                  "jchar *__qt_%1_tmp = %env->GetCharArrayElements(%in, nullptr);\n"+
                                  "jsize %2 = %env->GetArrayLength(%in);\n"+
                                  "QChar* %out = new QChar[size_t(%2)];\n"+
                                  "for(int i=0; i<%2; ++i){\n"+
                                  "    %out[i] = QChar(__qt_%1_tmp[i]);\n"+
                                  "}"}
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
            }
            ModifyArgument{
                index: 3
                invalidateAfterUse: true
            }
            since: 6
        }
        ModifyFunction{
            signature: "toUnicode(const char*,int,QStringConverterBase::State*)const"
            ModifyArgument{
                index: 0
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = qtjambi_cast<jstring>(%env, %in);"}
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "byte[]"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "ConstCharPointerArray _%in(%env, %in, jsize(%2));\n"+
                                  "jbyteArray %out = _%in;"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JByteArrayPointer %out(%env, jbyteArray(%in));"}
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "// nothing"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "int %out = __qt_%1.size();"}
                }
            }
            ModifyArgument{
                index: 3
                invalidateAfterUse: true
            }
            since: 6
        }
        ModifyFunction{
            signature: "codecForName(const char*)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        ModifyFunction{
            signature: "makeDecoder(QFlags<QStringConverterBase::Flag>) const"
            ModifyArgument{
                index: 1
                ReplaceDefaultExpression{
                    expression: "QStringConverterBase.Flag.WriteBom"
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "makeEncoder(QFlags<QStringConverterBase::Flag>) const"
            ModifyArgument{
                index: 1
                ReplaceDefaultExpression{
                    expression: "QStringConverterBase.Flag.WriteBom"
                }
            }
            since: 6
        }
        until: 5
    }
    
    ObjectType{
        name: "QTextDecoder"
        ModifyFunction{
            signature: "toUnicode(const char*,int)"
            Remove{
            }
        }
        ModifyFunction{
            signature: "toUnicode(QString*,const char*,int)"
            remove: RemoveFlag.All
        }
    }
    
    ObjectType{
        name: "QTextEncoder"
        ModifyFunction{
            signature: "fromUnicode(const QChar*,int)"
            Remove{
            }
        }
        ModifyFunction{
            signature: "fromUnicode(QStringView)"
            remove: RemoveFlag.All
            since: [5, 10]
        }
    }
    
    ObjectType{
        name: "QTimeLine"
    }
    
    ObjectType{
        name: "QTranslator"
        ExtraIncludes{
            Include{
                fileName: "QtJambi/CoreAPI"
                location: Include.Global
            }
        }
        ExtraIncludes{
            Include{
                fileName: "QTextCodec"
                location: Include.Global
                until: 5
            }
            Include{
                fileName: "QtCore/QSharedPointer"
                location: Include.Global
            }
            Include{
                fileName: "memory"
                location: Include.Global
            }
        }
        ModifyFunction{
            signature: "load(const unsigned char*,int,QString)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "byte[]"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "struct ObjectUserData : QtJambiObjectData{\n"+
                                  "    ObjectUserData(JNIEnv *env, jbyteArray data) : QtJambiObjectData(), array(new JByteArrayPointer(env, data, false)) {\n"+
                                  "    }\n"+
                                  "    QSharedPointer<JByteArrayPointer> array;\n"+
                                  "    QTJAMBI_OBJECTUSERDATA_ID_IMPL(static,)\n"+
                                  "};\n"+
                                  "std::unique_ptr<ObjectUserData> userData(new ObjectUserData(%env, %in));\n"+
                                  "const unsigned char* %out = reinterpret_cast<const unsigned char*>(userData->array->pointer());\n"+
                                  "int %2 = userData->array->size();"}
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
            }
            ModifyArgument{
                index: 0
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = %in;\n"+
                                  "if(%out){\n"+
                                  "    ObjectUserData *oldUserData = QTJAMBI_GET_OBJECTUSERDATA(ObjectUserData, __qt_this);\n"+
                                  "    QTJAMBI_SET_OBJECTUSERDATA(ObjectUserData, __qt_this, userData.release());\n"+
                                  "    if(oldUserData)\n"+
                                  "        delete oldUserData;\n"+
                                  "}"}
                }
            }
        }
        ModifyFunction{
            signature: "translate(const char*,const char*,const char*,int)const"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
            ModifyArgument{
                index: 3
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
    }
    
    ObjectType{
        name: "QFileSystemWatcher"
        ExtraIncludes{
            Include{
                fileName: "QStringList"
                location: Include.Global
            }
        }
    }
    
    ObjectType{
        name: "QTextCodec::ConverterState"
        Include{
            fileName: "QTextCodec"
            location: Include.Global
        }
        until: 5
    }
    
    ObjectType{
        name: "QBuffer"
        ModifyFunction{
            signature: "buffer()"
            Remove{
            }
        }
        ModifyFunction{
            signature: "QBuffer(QByteArray*,QObject*)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
                ReferenceCount{
                    variableName: "strongDataReference"
                    action: ReferenceCount.Set
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QByteArray* %out = qtjambi_cast<QByteArray*>(%env, %in);"}
                }
            }
        }
        ModifyFunction{
            signature: "setBuffer(QByteArray*)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
                ReferenceCount{
                    variableName: "strongDataReference"
                    action: ReferenceCount.Set
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QByteArray* %out = qtjambi_cast<QByteArray*>(%env, %in);"}
                }
            }
        }
        ModifyFunction{
            signature: "setData(const char*,int)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "byte[]"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JByteArrayPointer %out(%env, jbyteArray(%in));\n"+
                                  "jint %2 = %out.size();"}
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
            }
            until: [6,4]
        }
        ModifyFunction{
            signature: "setData(const char*,qsizetype)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "byte[]"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "JByteArrayPointer %out(%env, jbyteArray(%in));\n"+
                                  "jint %2 = %out.size();"}
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
            }
            since: [6,5]
        }
    }
    
    ObjectType{
        name: "QTimer"
        InjectCode{
            target: CodeClass.Java
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QTimer___"
                quoteBeforeLine: "}// class"
            }
        }
    }
    
    ObjectType{
        name: "QProcess"
        ppCondition: "QT_CONFIG(process)"
        ModifyFunction{
            signature: "readChannelMode()const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "setReadChannelMode(QProcess::ProcessChannelMode)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "setStandardOutputProcess(QProcess*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcStandardOutputProcess"
                    action: ReferenceCount.Set
                }
            }
        }
        ModifyFunction{
            signature: "setStandardOutputFile(QString,QFlags<QIODevice::OpenModeFlag>)"
            InjectCode{
                target: CodeClass.Java
                position: Position.Beginning
                ArgumentMap{
                    index: 2
                    metaName: "%2"
                }
                Text{content: "if(%2.value()!=io.qt.core.QIODevice.OpenModeFlag.Append.value() && %2.value()!=io.qt.core.QIODevice.OpenModeFlag.Truncate.value())\n"+
                              "    throw new IllegalArgumentException(\"Argument %2: Append or Truncate expected\");"}
            }
            until: 5
        }
        ModifyFunction{
            signature: "setStandardErrorFile(QString,QFlags<QIODevice::OpenModeFlag>)"
            InjectCode{
                target: CodeClass.Java
                position: Position.Beginning
                ArgumentMap{
                    index: 2
                    metaName: "%2"
                }
                Text{content: "if(%2.value()!=io.qt.core.QIODevice.OpenModeFlag.Append.value() && %2.value()!=io.qt.core.QIODevice.OpenModeFlag.Truncate.value())\n"+
                              "    throw new IllegalArgumentException(\"Argument %2: Append or Truncate expected\");"}
            }
            until: 5
        }
        ModifyFunction{
            signature: "setStandardOutputFile(QString,QFlags<QIODeviceBase::OpenModeFlag>)"
            InjectCode{
                target: CodeClass.Java
                position: Position.Beginning
                ArgumentMap{
                    index: 2
                    metaName: "%2"
                }
                Text{content: "if(%2.value()!=io.qt.core.QIODeviceBase.OpenModeFlag.Append.value() && %2.value()!=io.qt.core.QIODeviceBase.OpenModeFlag.Truncate.value())\n"+
                              "    throw new IllegalArgumentException(\"Argument %2: Append or Truncate expected\");"}
            }
            since: 6
        }
        ModifyFunction{
            signature: "setStandardErrorFile(QString,QFlags<QIODeviceBase::OpenModeFlag>)"
            InjectCode{
                target: CodeClass.Java
                position: Position.Beginning
                ArgumentMap{
                    index: 2
                    metaName: "%2"
                }
                Text{content: "if(%2.value()!=io.qt.core.QIODeviceBase.OpenModeFlag.Append.value() && %2.value()!=io.qt.core.QIODeviceBase.OpenModeFlag.Truncate.value())\n"+
                              "    throw new IllegalArgumentException(\"Argument %2: Append or Truncate expected\");"}
            }
            since: 6
        }
        ModifyFunction{
            signature: "start(const QString &, const QStringList &,QFlags<QIODeviceBase::OpenModeFlag>)"
            ModifyArgument{
                index: 2
                ReplaceDefaultExpression{
                    expression: "java.util.Collections.emptyList()"
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "execute(const QString &, const QStringList &)"
            ModifyArgument{
                index: 2
                ReplaceDefaultExpression{
                    expression: "java.util.Collections.emptyList()"
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "startDetached(QString,QStringList,QString,long long*)"
            ModifyArgument{
                index: 2
                since: 6
                ReplaceDefaultExpression{
                    expression: "java.util.Collections.emptyList()"
                }
            }
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.lang.Long"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = %in ? QtJambiAPI::toJavaLongObject(%env, pid) : nullptr;"}
                }
            }
            ModifyArgument{
                index: 4
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "long long pid(0);\n"+
                                  "long long * %out = &pid;"}
                }
            }
        }
        ModifyFunction{
            signature: "startDetached(long long*)"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.lang.Long"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = %in ? QtJambiAPI::toJavaLongObject(%env, pid) : nullptr;"}
                }
            }
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "long long pid(0);\n"+
                                  "long long * %out = &pid;"}
                }
            }
            since: [5, 10]
        }
    }
    
    
    ObjectType{
        name: "QSignalMapper"
        ExtraIncludes{
            Include{
                fileName: "qwidget.h"
                suppressed: true
                location: Include.Global
            }
            Include{
                fileName: "hashes.h"
                location: Include.Local
            }
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QSignalMapper___"
                quoteBeforeLine: "}// class"
            }
        }
        ExtraIncludes{
            Include{
                fileName: "QtJambi/JavaAPI"
                location: Include.Global
            }
        }
        ModifyFunction{
            signature: "mapped(QWidget*)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "io.qt.widgets.QWidget"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "%out = qtjambi_cast<jobject>(%env, reinterpret_cast<QObject*>(%in));"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QWidget* %out = reinterpret_cast<QWidget*>(qtjambi_cast<QObject*>(%env, %in));"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "mappedWidget(QWidget*)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "io.qt.widgets.QWidget"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "%out = qtjambi_cast<jobject>(%env, reinterpret_cast<QObject*>(%in));"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QWidget* %out = reinterpret_cast<QWidget*>(qtjambi_cast<QObject*>(%env, %in));"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "removeMappings(QObject*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcMappings"
                    action: ReferenceCount.Take
                }
            }
            InjectCode{
                target: CodeClass.Java
                position: Position.End
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                Text{content: "if (__rcObjectForObject!=null) __rcObjectForObject.remove(sender);"}
            }
        }
        ModifyFunction{
            signature: "setMapping(QObject*,QObject*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcMappings"
                    action: ReferenceCount.Add
                }
            }
            InjectCode{
                target: CodeClass.Java
                position: Position.End
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                ArgumentMap{
                    index: 2
                    metaName: "%2"
                }
                Text{content: "if (%2 == null)\n"+
                              "    if(__rcObjectForObject!=null)\n"+
                              "        __rcObjectForObject.remove(%1);\n"+
                              "else{\n"+
                              "    if(__rcObjectForObject==null)\n"+
                              "        __rcObjectForObject = new java.util.HashMap<>();\n"+
                              "    __rcObjectForObject.put(%1,%2);\n"+
                              "}"}
            }
        }
        ModifyFunction{
            signature: "setMapping(QObject*,QWidget*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcMappings"
                    action: ReferenceCount.Add
                }
            }
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "io.qt.widgets.QWidget"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "%out = qtjambi_cast<jobject>(%env, reinterpret_cast<QObject*>(%in));"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QWidget* %out = reinterpret_cast<QWidget*>(qtjambi_cast<QObject*>(%env, %in));"}
                }
            }
            InjectCode{
                target: CodeClass.Java
                position: Position.End
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                ArgumentMap{
                    index: 2
                    metaName: "%2"
                }
                Text{content: "if (%2 == null)\n"+
                              "    if(__rcObjectForObject!=null)\n"+
                              "        __rcObjectForObject.remove(%1);\n"+
                              "else{\n"+
                              "    if(__rcObjectForObject==null)\n"+
                              "        __rcObjectForObject = new java.util.HashMap<>();\n"+
                              "    __rcObjectForObject.put(%1,%2);\n"+
                              "}"}
            }
            until: 5
        }
        ModifyFunction{
            signature: "setMapping(QObject*,QString)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcMappings"
                    action: ReferenceCount.Add
                }
            }
        }
        ModifyFunction{
            signature: "setMapping(QObject*,int)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcMappings"
                    action: ReferenceCount.Add
                }
            }
        }
        ModifyFunction{
            signature: "mapping(QWidget*)const"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "io.qt.widgets.QWidget"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "%out = qtjambi_cast<jobject>(%env, reinterpret_cast<QObject*>(%in));"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QWidget* %out = reinterpret_cast<QWidget*>(qtjambi_cast<QObject*>(%env, %in));"}
                }
            }
            until: 5
        }
    }
    
    ObjectType{
        name: "QThreadStorage"
        template: true
        TemplateArguments{
            arguments: ["JObjectWrapper"]
        }
    }
    
    ObjectType{
        name: "QThreadStorage<JObjectWrapper>"
        isGeneric: true
        ExtraIncludes{
            Include{
                fileName: "QtJambi/JObjectWrapper"
                location: Include.Global
            }
        }
    }
    
    ObjectType{
        name: "QThread"
        ExtraIncludes{
            Include{
                fileName: "QtJambi/JavaAPI"
                location: Include.Global
            }
        }
        ModifyFunction{
            signature: "wait(ulong)"
            rename: "join"
            threadAffinity: false
        }
        ModifyFunction{
            signature: "isRunning()const"
            threadAffinity: false
        }
        ModifyFunction{
            signature: "terminate()"
            threadAffinity: false
        }
        ModifyFunction{
            signature: "isInterruptionRequested()const"
            threadAffinity: false
        }
        ModifyFunction{
            signature: "isFinished()const"
            threadAffinity: false
        }
        ModifyFunction{
            signature: "setStackSize(uint)"
            threadAffinity: false
        }
        ModifyFunction{
            signature: "stackSize()const"
            threadAffinity: false
        }
        ModifyFunction{
            signature: "exec()"
            threadAffinity: false
        }
        ModifyFunction{
            signature: "exit(int)"
            threadAffinity: false
        }
        ModifyFunction{
            signature: "quit()"
            threadAffinity: false
        }
        ModifyFunction{
            signature: "run()"
            noExcept: true
            blockExceptions: true
            threadAffinity: false
        }
        ModifyFunction{
            signature: "setPriority(QThread::Priority)"
            threadAffinity: false
        }
        ModifyFunction{
            signature: "priority()const"
            threadAffinity: false
        }
        ModifyFunction{
            signature: "eventDispatcher()const"
            threadAffinity: false
        }
        ModifyFunction{
            signature: "setEventDispatcher(QAbstractEventDispatcher*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcEventDispatcher"
                    action: ReferenceCount.Set
                }
            }
        }
        ModifyFunction{
            signature: "QThread(QObject*)"
            InjectCode{
                target: CodeClass.Java
                position: Position.End
                Text{content: "initialize(null);"}
            }
        }
        ModifyFunction{
            signature: "wait(QDeadlineTimer)"
            rename: "join"
            threadAffinity: false
            ModifyArgument{
                index: 1
                ReplaceDefaultExpression{
                    expression: "new QDeadlineTimer(QDeadlineTimer.ForeverConstant.Forever)"
                }
            }
            since: [5, 15]
        }
        ModifyFunction{
            signature: "start(QThread::Priority)"
            threadAffinity: false
            InjectCode{
                target: CodeClass.Native
                position: Position.Beginning
                Text{content: "if(!__qt_this->parent() && !__qt_this->isRunning()){\n"+
                              "    if(!Java::QtCore::QThread::javaThread(%env, __this))\n"+
                              "        QtJambiAPI::setCppOwnership(%env, __this);\n"+
                              "}"}
            }
        }
        ModifyFunction{
            signature: "requestInterruption()"
            threadAffinity: false
            InjectCode{
                target: CodeClass.Java
                position: Position.End
                Text{content: "Thread t = javaThread();\n"+
                              "if(t!=null)\n"+
                              "    t.interrupt();"}
            }
        }
        InjectCode{
            target: CodeClass.Java
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QThread___"
                quoteBeforeLine: "}// class"
            }
        }
    }
    
    EnumType{
        name: "QThread::Priority"
    }
    
    ObjectType{
        name: "QObjectCleanupHandler"
        ModifyFunction{
            signature: "add(QObject*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    action: ReferenceCount.Ignore
                }
            }
        }
        ModifyFunction{
            signature: "remove(QObject*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    action: ReferenceCount.Ignore
                }
            }
        }
    }
    
    ObjectType{
        name: "QObject"
        implementing: "QtSignalEmitterInterface, QtSignalBlockerInterface, QtThreadAffineInterface"
        ExtraIncludes{
            Include{
                fileName: "QtCore/QRegularExpression"
                location: Include.Global
            }
            Include{
                fileName: "QtCore/QThread"
                location: Include.Global
            }
            Include{
                fileName: "QtJambi/CoreAPI"
                location: Include.Global
            }
            Include{
                fileName: "QtJambi/JObjectWrapper"
                location: Include.Global
            }
            Include{
                fileName: "utils_p.h"
                location: Include.Local
            }
        }
        ModifyFunction{
            signature: "destroyed(QObject *)"
            ModifyArgument{
                index: 1
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "%out = CoreAPI::fromDestroyedQObject(%env, %in);"}
                }
            }
        }
        ModifyFunction{
            signature: "setObjectName(QAnyStringView)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "bindingStorage() const"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "dumpObjectTree()"
            remove: RemoveFlag.All
            since: [5, 9]
            until: 5
        }
        ModifyFunction{
            signature: "dumpObjectInfo()"
            remove: RemoveFlag.All
            since: [5, 9]
            until: 5
        }
        ModifyFunction{
            signature: "childEvent(QChildEvent*)"
            ModifyArgument{
                index: 1
                invalidateAfterUse: true
            }
        }
        ModifyFunction{
            signature: "customEvent(QEvent*)"
            ModifyArgument{
                index: 1
                invalidateAfterUse: true
            }
        }
        ModifyFunction{
            signature: "event(QEvent*)"
            ModifyArgument{
                index: 1
                invalidateAfterUse: true
            }
        }
        ModifyFunction{
            signature: "eventFilter(QObject*,QEvent*)"
            ModifyArgument{
                index: 2
                invalidateAfterUse: true
            }
        }
        ModifyFunction{
            signature: "timerEvent(QTimerEvent*)"
            ModifyArgument{
                index: 1
                invalidateAfterUse: true
            }
        }
        ModifyFunction{
            signature: "installEventFilter(QObject*)"
            threadAffinity: true
            ModifyArgument{
                index: 1
                threadAffinity: true
                ReferenceCount{
                    variableName: "__rcEventFilters"
                    action: ReferenceCount.Add
                }
            }
        }
        ModifyFunction{
            signature: "removeEventFilter(QObject*)"
            threadAffinity: true
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcEventFilters"
                    action: ReferenceCount.Take
                }
            }
        }
        ModifyFunction{
            signature: "setParent(QObject*)"
            threadAffinity: true
            ModifyArgument{
                index: 1
                threadAffinity: true
                ReferenceCount{
                    action: ReferenceCount.Ignore
                }
            }
        }
        ModifyFunction{
            signature: "setProperty(const char *, QVariant)"
            threadAffinity: true
        }
        ModifyFunction{
            signature: "thread()const"
            threadAffinity: false
        }
        ModifyFunction{
            signature: "deleteLater()"
            threadAffinity: false
            Rename{
                to: "disposeLater"
            }
        }
        ExtraIncludes{
            Include{
                fileName: "io.qt.*"
                location: Include.Java
            }
            Include{
                fileName: "java.util.function.Supplier"
                location: Include.Java
            }
        }
        ModifyFunction{
            signature: "bindingStorage()"
            access: Modification.Private
            since: 6
        }
        InjectCode{
            target: CodeClass.Java
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QObject___"
                quoteBeforeLine: "}// class"
            }
        }
        InjectCode{
            target: CodeClass.Java
            until: 5
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QObject_5__"
                quoteBeforeLine: "}// class"
            }
        }
        InjectCode{
            target: CodeClass.Java
            since: 6
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QObject_6__"
                quoteBeforeLine: "}// class"
            }
        }
        ModifyFunction{
            signature: "startTimer(int, Qt::TimerType)"
            threadAffinity: true
            InjectCode{
                target: CodeClass.Java
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                Text{content: "if(%1 < 0){\n"+
                              "    throw new IllegalArgumentException(\"Timers cannot have negative intervals.\");\n"+
                              "}\n"+
                              "if(QAbstractEventDispatcher.instance()==null){\n"+
                              "    throw new RuntimeException(\"Timers can only be used with threads providing an event dispatcher.\");\n"+
                              "}"}
            }
        }
        ModifyFunction{
            signature: "killTimer(int)"
            threadAffinity: true
        }
        ModifyFunction{
            signature: "setParent(QObject*)"
            InjectCode{
                target: CodeClass.Native
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                Text{content: "if(__qt_this->isWidgetType()) {\n"+
                              "    if(!__qt_%1 || __qt_%1->isWidgetType()) {\n"+
                              "        Java::QtWidgets::QWidget::setParent(%env, qtjambi_cast<jobject>(%env, __qt_this), qtjambi_cast<jobject>(%env, __qt_%1));\n"+
                              "        return;\n"+
                              "    }else {\n"+
                              "        JavaException::raiseIllegalArgumentException(%env, \"Cannot set non-widget object as widget's parent.\" QTJAMBI_STACKTRACEINFO );\n"+
                              "    }\n"+
                              "}"}
            }
        }
        ModifyFunction{
            signature: "moveToThread(QThread*)"
            threadAffinity: false
            InjectCode{
                target: CodeClass.Native
                Text{content: "QThread* objectThread = __qt_this->thread();\n"+
                              "if (objectThread == __qt_thread0) {\n"+
                              "    return;\n"+
                              "}\n"+
                              "if (objectThread && objectThread != QThread::currentThread()) {\n"+
                              "    JavaException::raiseQThreadAffinityException(%env, \"QObject::moveToThread: Current thread is not the object's thread\" QTJAMBI_STACKTRACEINFO,\n"+
                              "            __this,\n"+
                              "            objectThread, QThread::currentThread()\n"+
                              "        );\n"+
                              "    return;\n"+
                              "}"}
            }
        }
        ModifyFunction{
            signature: "inherits(const char*)const"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        ModifyFunction{
            signature: "receivers(const char*)const"
            InjectCode{
                target: CodeClass.Java
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                Text{content: "if(%1==null || %1.isEmpty())\n"+
                              "    return 0;\n"+
                              "if(!%1.startsWith(\"2\")){\n"+
                              "    io.qt.core.QMetaMethod method = metaObject().method(%1);\n"+
                              "    if(method!=null && method.methodType()==io.qt.core.QMetaMethod.MethodType.Signal) {\n"+
                              "        %1 = \"2\" + method.cppMethodSignature();\n"+
                              "    }\n"+
                              "}"}
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        ModifyFunction{
            signature: "property(const char*)const"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.Beginning
                since: 6
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                ArgumentMap{
                    index: 0
                    metaName: "%0"
                }
                Text{content: "if(QtJambiObjectData::isRejectedUserProperty(__qt_this, __qt_%1)){\n"+
                              "    QTJAMBI_TRY_RETURN(__java_return_value,nullptr);\n"+
                              "}"}
            }
        }
        ModifyFunction{
            signature: "setProperty(const char*,QVariant)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.Beginning
                since: 6
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                ArgumentMap{
                    index: 0
                    metaName: "%0"
                }
                Text{content: "if(QtJambiObjectData::isRejectedUserProperty(__qt_this, __qt_%1)){\n"+
                              "    QTJAMBI_TRY_RETURN(__java_return_value,false);\n"+
                              "}"}
            }
        }
        ModifyFunction{
            signature: "dynamicPropertyNames() const"
            ModifyArgument{
                index: 0
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)\n"+
                                  "for(QByteArray name : QList<QByteArray>(%in)){\n"+
                                  "    if(QtJambiObjectData::isRejectedUserProperty(__qt_this, name))\n"+
                                  "    %in.removeAll(name);\n"+
                                  "}\n"+
                                  "#endif\n"+
                                  "%out = qtjambi_cast<jobject>(%env, %in);"}
                }
            }
        }
        ModifyFunction{
            signature: "findChild<T>(QString, QFlags<Qt::FindChildOption>) const"
            Instantiation{
                proxyCall: "qtjambi_findChild"
                Argument{
                    type: "QTimer*"
                }
                ModifyArgument{
                    index: 0
                    ReplaceType{
                        modifiedType: "T"
                        modifiedJniType: "jobject"
                    }
                }
                AddTypeParameter{
                    name: "T"
                    extending: "io.qt.core.QObject"
                }
                AddArgument{
                    index: 1
                    defaultExpression: "QObject.class"
                    name: "type"
                    type: "java.lang.Class<T>"
                }
            }
            Instantiation{
                proxyCall: "qtjambi_findChild"
                Argument{
                    type: "QObject*"
                }
                ModifyArgument{
                    index: 0
                    ReplaceType{
                        modifiedType: "io.qt.core.QObject"
                    }
                }
            }
        }
        ModifyFunction{
            signature: "findChildren<T>(QString, QFlags<Qt::FindChildOption>) const"
            Instantiation{
                proxyCall: "qtjambi_findChildren"
                Argument{
                    type: "QTimer*"
                }
                ModifyArgument{
                    index: 0
                    ReplaceType{
                        modifiedType: "io.qt.core.QList<T>"
                    }
                }
                AddTypeParameter{
                    name: "T"
                    extending: "io.qt.core.QObject"
                }
                AddArgument{
                    index: 1
                    defaultExpression: "QObject.class"
                    name: "type"
                    type: "java.lang.Class<T>"
                }
            }
            Instantiation{
                proxyCall: "qtjambi_findChildren"
                Argument{
                    type: "QObject*"
                }
                ModifyArgument{
                    index: 0
                    ReplaceType{
                        modifiedType: "io.qt.core.QList<io.qt.core.QObject>"
                    }
                }
            }
        }
        ModifyFunction{
            signature: "findChildren<T>(QRegularExpression, QFlags<Qt::FindChildOption>) const"
            Instantiation{
                proxyCall: "qtjambi_findChildren"
                Argument{
                    type: "QTimer*"
                }
                ModifyArgument{
                    index: 0
                    ReplaceType{
                        modifiedType: "io.qt.core.QList<T>"
                    }
                }
                AddTypeParameter{
                    name: "T"
                    extending: "io.qt.core.QObject"
                }
                AddArgument{
                    index: 1
                    name: "type"
                    type: "java.lang.Class<T>"
                }
            }
            Instantiation{
                proxyCall: "qtjambi_findChildren"
                Argument{
                    type: "QObject*"
                }
                ModifyArgument{
                    index: 0
                    ReplaceType{
                        modifiedType: "io.qt.core.QList<io.qt.core.QObject>"
                    }
                }
            }
        }
        ModifyFunction{
            signature: "findChildren<T>(QFlags<Qt::FindChildOption>) const"
            Instantiation{
                proxyCall: "qtjambi_findChildren"
                Argument{
                    type: "QTimer*"
                }
                ModifyArgument{
                    index: 0
                    ReplaceType{
                        modifiedType: "io.qt.core.QList<T>"
                    }
                }
                AddTypeParameter{
                    name: "T"
                    extending: "io.qt.core.QObject"
                }
                AddArgument{
                    index: 1
                    name: "type"
                    type: "java.lang.Class<T>"
                }
            }
            Instantiation{
                proxyCall: "qtjambi_findChildren"
                Argument{
                    type: "QObject*"
                }
                ModifyArgument{
                    index: 0
                    ReplaceType{
                        modifiedType: "io.qt.core.QList<io.qt.core.QObject>"
                    }
                }
            }
        }
        ModifyFunction{
            signature: "findChildren<T>(QRegExp, QFlags<Qt::FindChildOption>) const"
            Instantiation{
                proxyCall: "qtjambi_findChildren"
                Argument{
                    type: "QTimer*"
                }
                ModifyArgument{
                    index: 0
                    ReplaceType{
                        modifiedType: "io.qt.core.QList<T>"
                    }
                }
                AddTypeParameter{
                    name: "T"
                    extending: "io.qt.core.QObject"
                }
                AddArgument{
                    index: 1
                    name: "type"
                    type: "java.lang.Class<T>"
                }
            }
            Instantiation{
                proxyCall: "qtjambi_findChildren"
                Argument{
                    type: "QObject*"
                }
                ModifyArgument{
                    index: 0
                    ReplaceType{
                        modifiedType: "io.qt.core.QList<io.qt.core.QObject>"
                    }
                }
            }
            until: [5, 15]
        }
    }
    
    ObjectType{
        name: "QSignalBlocker"
        implementing: "AutoCloseable"
        ModifyFunction{
            signature: "QSignalBlocker(QObject&)"
            remove: RemoveFlag.All
        }
        InjectCode{
            target: CodeClass.Java
            Text{content: "public void close(){dispose();}"}
        }
    }
    
    ObjectType{
        name: "QCoreApplication"
        isValueOwner: true
        ExtraIncludes{
            Include{
                fileName: "QStringList"
                location: Include.Global
            }
        }
        ModifyFunction{
            signature: "notify(QObject*,QEvent*)"
            noExcept: true
            blockExceptions: true
            ModifyArgument{
                index: 1
                threadAffinity: true
            }
            ModifyArgument{
                index: 2
                invalidateAfterUse: true
            }
        }
        ModifyFunction{
            signature: "removePostedEvents(QObject*,int)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    action: ReferenceCount.Ignore
                }
            }
        }
        ModifyFunction{
            signature: "sendEvent(QObject *, QEvent *)"
            rethrowExceptions: true
            ModifyArgument{
                index: 1
                threadAffinity: true
            }
        }
        ModifyFunction{
            signature: "installTranslator(QTranslator *)"
            threadAffinity: Affinity.UI
            ModifyArgument{
                index: 1
                threadAffinity: true
                ReferenceCount{
                    variableName: "__rcTranslators"
                    action: ReferenceCount.Add
                }
            }
        }
        ModifyFunction{
            signature: "removeTranslator(QTranslator *)"
            threadAffinity: Affinity.UI
            ModifyArgument{
                index: 1
                threadAffinity: true
                ReferenceCount{
                    variableName: "__rcTranslators"
                    action: ReferenceCount.Take
                }
            }
        }
        ModifyFunction{
            signature: "sendPostedEvents(QObject*, int)"
            rethrowExceptions: true
        }
        ModifyFunction{
            signature: "postEvent(QObject*,QEvent*,int)"
            rethrowExceptions: true
            ModifyArgument{
                index: 2
                DefineOwnership{
                    codeClass: CodeClass.Native
                    ownership: Ownership.Cpp
                }
            }
        }
        ModifyFunction{
            signature: "instance()"
            ModifyArgument{
                index: 0
                DefineOwnership{
                    codeClass: CodeClass.Native
                    ownership: Ownership.Cpp
                }
            }
        }
        ModifyFunction{
            signature: "setLibraryPaths(const QStringList &)"
            ppCondition: "QT_CONFIG(library)"
        }
        ModifyFunction{
            signature: "addLibraryPath(const QString &)"
            ppCondition: "QT_CONFIG(library)"
        }
        ModifyFunction{
            signature: "removeLibraryPath(const QString &)"
            ppCondition: "QT_CONFIG(library)"
        }
        ModifyFunction{
            signature: "libraryPaths()"
            ppCondition: "QT_CONFIG(library)"
        }
        ModifyFunction{
            signature: "setEventDispatcher(QAbstractEventDispatcher*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    action: ReferenceCount.Ignore
                }
            }
            InjectCode{
                position: Position.End
                Text{content: "QtJambi_LibraryUtilities.internal.setReferenceCount(instance().thread(), QThread.class, \"__rcEventDispatcher\", false, false, eventDispatcher);"}
            }
        }
        ExtraIncludes{
            Include{
                fileName: "QtJambi/CoreAPI"
                location: Include.Global
            }
            Include{
                fileName: "QtCore/private/qthread_p.h"
                location: Include.Global
            }
            Include{
                fileName: "QtCore/private/qcoreapplication_p.h"
                location: Include.Global
            }
            Include{
                fileName: "utils_p.h"
                location: Include.Local
            }
        }
        ModifyFunction{
            signature: "QCoreApplication(int &, char **, int)"
            Access{
                modifiers: Modification.Protected
            }
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "// nothing to do"}
                }
            }
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.lang.String[]"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "std::unique_ptr<ApplicationData> applicationData(new ApplicationData(%env, jobjectArray(%in)));\n"+
                                  "char** %out = applicationData->chars();\n"+
                                  "int& __qt_%1 = applicationData->size();"}
                }
            }
            ModifyArgument{
                index: 3
                RemoveArgument{
                }
            }
            InjectCode{
                target: CodeClass.Java
                Text{content: "if(!__qt_isInitializing){\n"+
                              "    throw new IllegalAccessError(\"Not allowed to instantiate QCoreApplication. Please use QCoreApplication.initialize() instead.\");\n"+
                              "}"}
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.End
                Text{content: "applicationData->update(%env);\n"+
                              "QTJAMBI_SET_OBJECTUSERDATA(ApplicationData, __qt_this, applicationData.release());"}
            }
        }
        ModifyFunction{
            signature: "exec()"
            InjectCode{
                target: CodeClass.Native
                position: Position.Beginning
                Text{content: "bool useQGuiApplicationExec = false;\n"+
                              "QCoreApplication* instance = QCoreApplication::instance();\n"+
                              "if (!instance)\n"+
                              "    JavaException::raiseRuntimeException(%env, \"QCoreApplication has not been initialized with QCoreApplication.initialize()\" QTJAMBI_STACKTRACEINFO );\n"+
                              "else if(instance->inherits(\"QGuiApplication\")){\n"+
                              "    useQGuiApplicationExec = true;\n"+
                              "    QTJAMBI_TRY_ANY{\n"+
                              "        Java::QtGui::QGuiApplication::getClass(%env);\n"+
                              "    }QTJAMBI_CATCH_ANY{\n"+
                              "        useQGuiApplicationExec = false;\n"+
                              "    }QTJAMBI_TRY_END\n"+
                              "    if(useQGuiApplicationExec)\n"+
                              "        __java_return_value = Java::QtGui::QGuiApplication::exec(%env);\n"+
                              "}else if(instance->thread()!=QThread::currentThread())\n"+
                              "    JavaException::raiseRuntimeException(%env, \"exec() must be called from the main thread.\" QTJAMBI_STACKTRACEINFO );\n"+
                              "else if(QThreadData::get2(instance->thread())->eventLoops.size()>0)\n"+
                              "    JavaException::raiseRuntimeException(%env, \"The event loop is already running.\" QTJAMBI_STACKTRACEINFO );\n"+
                              "if(!useQGuiApplicationExec){"}
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.End
                Text{content: "}"}
            }
        }
        ModifyFunction{
            signature: "sendPostedEvents(QObject *, int)"
            ModifyArgument{
                index: 1
                threadAffinity: true
            }
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QCoreApplication___"
                quoteBeforeLine: "}// class"
            }
        }
        InjectCode{
            since: [6, 2]
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QCoreApplication__62_"
                quoteBeforeLine: "}// class"
            }
        }
        InjectCode{
            since: [6, 5]
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QCoreApplication__65_"
                quoteBeforeLine: "}// class"
            }
        }
        ModifyFunction{
            signature: "translate(const char*,const char*,const char*,int)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
            ModifyArgument{
                index: 3
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        ModifyFunction{
            signature: "resolveInterface(const char *, int)const"
            access: Modification.Private
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "<QNativeInterface extends io.qt.QtObjectInterface> QNativeInterface"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jobject %out = QtJambiAPI::convertNativeToJavaObject(%env, %in, %1, false, false);\n"+
                                  "CoreAPI::registerDependency(%env, %out, __this_nativeId);"}
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.Class<QNativeInterface>"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "if(inherits(\"QGuiApplication\")){\n"+
                                  "    bool classNotFound = false;\n"+
                                  "    QTJAMBI_TRY_ANY{\n"+
                                  "        Java::QtGui::QGuiApplication::getClass(%env);\n"+
                                  "    }QTJAMBI_CATCH_ANY{\n"+
                                  "        classNotFound = true;\n"+
                                  "    }QTJAMBI_TRY_END\n"+
                                  "    if(!classNotFound)\n"+
                                  "        return Java::QtGui::QGuiApplication::resolveInterface(%env, CoreAPI::javaObject(__this_nativeId, %env), %in);\n"+
                                  "}\n"+
                                  "CoreAPI::NITypeInfo info = CoreAPI::getNativeInterfaceInfo(%env, %in);\n"+
                                  "const char* %out = info.name;"}
                }
            }
            ModifyArgument{
                index: 2
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "int %out = info.revision;"}
                }
                RemoveArgument{
                }
            }
            since: [6, 2]
        }
        ModifyFunction{
            signature: "checkPermission(QPermission)"
            ppCondition: "QT_CONFIG(permissions)"
            since: [6, 5]
        }
    }
    

    ValueType{
        name: "QPermission"
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QPermission___"
                quoteBeforeLine: "}// class"
            }
        }
        since: [6, 5]
    }

    ValueType{
        name: "QLocationPermission"
        ModifyFunction{
            signature: "operator=(QLocationPermission)"
            remove: RemoveFlag.All
        }
        implementing: "QPermission.Request"
        since: [6, 5]
    }

    EnumType{
        name: "QLocationPermission::Accuracy"
        since: [6, 5]
    }

    EnumType{
        name: "QLocationPermission::Availability"
        since: [6, 5]
    }

    ValueType{
        name: "QCalendarPermission"
        ModifyFunction{
            signature: "operator=(QCalendarPermission)"
            remove: RemoveFlag.All
        }
        implementing: "QPermission.Request"
        since: [6, 5]
    }

    ValueType{
        name: "QContactsPermission"
        ModifyFunction{
            signature: "operator=(QContactsPermission)"
            remove: RemoveFlag.All
        }
        implementing: "QPermission.Request"
        since: [6, 5]
    }

    ValueType{
        name: "QCameraPermission"
        ModifyFunction{
            signature: "operator=(QCameraPermission)"
            remove: RemoveFlag.All
        }
        implementing: "QPermission.Request"
        since: [6, 5]
    }

    ValueType{
        name: "QMicrophonePermission"
        ModifyFunction{
            signature: "operator=(QMicrophonePermission)"
            remove: RemoveFlag.All
        }
        implementing: "QPermission.Request"
        since: [6, 5]
    }

    ValueType{
        name: "QBluetoothPermission"
        ModifyFunction{
            signature: "operator=(QBluetoothPermission)"
            remove: RemoveFlag.All
        }
        implementing: "QPermission.Request"
        since: [6, 5]
    }

    ObjectType{
        name: "QSettings"
        ExtraIncludes{
            Include{
                fileName: "QStringList"
                location: Include.Global
            }
            Include{
                fileName: "QtJambi/JObjectWrapper"
                location: Include.Global
            }
        }
        ModifyFunction{
            signature: "setIniCodec(QTextCodec*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcIniCodec"
                    action: ReferenceCount.Set
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "setValue(const QString &, const QVariant &)"
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.lang.Object"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QVariant %out = QtJambiAPI::convertJavaObjectToQVariant(%env, %in);\n"+
                                  "if(__qt_value1.type()==QVariant::UserType){\n"+
                                  "    if(%out.userType()==qMetaTypeId<JCollectionWrapper>()){\n"+
                                  "        bool ok = false;\n"+
                                  "        QStringList stringList = %out.value<JCollectionWrapper>().toStringList(&ok);\n"+
                                  "        if(ok){\n"+
                                  "            %out.setValue(stringList);\n"+
                                  "        }else{\n"+
                                  "            QList<QVariant> variantList = %out.value<JCollectionWrapper>().toList();\n"+
                                  "            %out.setValue(variantList);\n"+
                                  "        }\n"+
                                  "    }else if(%out.userType()==qMetaTypeId<JMapWrapper>()){\n"+
                                  "        bool ok = false;\n"+
                                  "        QVariantMap stringMap = %out.value<JMapWrapper>().toStringMap(&ok);\n"+
                                  "        if(ok){\n"+
                                  "            %out.setValue(stringMap);\n"+
                                  "        }\n"+
                                  "    }\n"+
                                  "}"}
                }
            }
            until: [6, 3]
        }
        ModifyFunction{
            signature: "setValue(QAnyStringView, const QVariant &)"
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.lang.Object"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QVariant %out = QtJambiAPI::convertJavaObjectToQVariant(%env, %in);\n"+
                                  "if(__qt_value1.type()==QVariant::UserType){\n"+
                                  "    if(%out.userType()==qMetaTypeId<JCollectionWrapper>()){\n"+
                                  "        bool ok = false;\n"+
                                  "        QStringList stringList = %out.value<JCollectionWrapper>().toStringList(&ok);\n"+
                                  "        if(ok){\n"+
                                  "            %out.setValue(stringList);\n"+
                                  "        }else{\n"+
                                  "            QList<QVariant> variantList = %out.value<JCollectionWrapper>().toList();\n"+
                                  "            %out.setValue(variantList);\n"+
                                  "        }\n"+
                                  "    }else if(%out.userType()==qMetaTypeId<JMapWrapper>()){\n"+
                                  "        bool ok = false;\n"+
                                  "        QVariantMap stringMap = %out.value<JMapWrapper>().toStringMap(&ok);\n"+
                                  "        if(ok){\n"+
                                  "            %out.setValue(stringMap);\n"+
                                  "        }\n"+
                                  "    }\n"+
                                  "}"}
                }
            }
            since: [6, 4]
        }
        ModifyFunction{
            signature: "setSystemIniPath(const QString&)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "setUserIniPath(const QString&)"
            remove: RemoveFlag.All
            until: 5
        }
        InjectCode{
            target: CodeClass.Java
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QSettings__"
                quoteBeforeLine: "}// class"
            }
        }
        ModifyFunction{
            signature: "QSettings(QObject*)"
            blockExceptions: true
        }
        ModifyFunction{
            signature: "QSettings(QSettings::Format, QSettings::Scope, const QString&, const QString&, QObject*)"
            blockExceptions: true
        }
        ModifyFunction{
            signature: "QSettings(QSettings::Scope, const QString&, const QString&, QObject*)"
            blockExceptions: true
        }
        ModifyFunction{
            signature: "QSettings(const QString&, QSettings::Format, QObject*)"
            blockExceptions: true
        }
        ModifyFunction{
            signature: "QSettings(const QString&, const QString&, QObject*)"
            blockExceptions: true
        }
        ModifyFunction{
            signature: "setIniCodec(const char*)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "J2CStringBuffer %out(%env, jstring(%in));"}
                }
            }
            until: 5
        }
    }
    
    FunctionalType{
        name: "QSettings::ReadFunc"
        ExtraIncludes{
            Include{
                fileName: "QtCore/QIODevice"
                location: Include.Global
            }
        }
        ModifyArgument{
            index: 1
            invalidateAfterUse: true
        }
        ModifyArgument{
            index: 2
            invalidateAfterUse: true
        }
    }
    
    FunctionalType{
        name: "QSettings::WriteFunc"
        ExtraIncludes{
            Include{
                fileName: "QtCore/QIODevice"
                location: Include.Global
            }
        }
        ModifyArgument{
            index: 1
            invalidateAfterUse: true
        }
        ModifyArgument{
            index: 2
            invalidateAfterUse: true
        }
    }
    
    
    ObjectType{
        name: "QEvent"
        ModifyFunction{
            signature: "operator=(const QEvent &)"
            rename: "set"
            ModifyArgument{
                index: "return"
                replaceType: "void"
            }
        }
        ModifyFunction{
            signature: "clone()const"
            ModifyArgument{
                index: "return"
                DefineOwnership{
                    codeClass: CodeClass.Native
                    ownership: Ownership.Java
                }
                DefineOwnership{
                    codeClass: CodeClass.Shell
                    ownership: Ownership.Cpp
                }
            }
            since: 6
        }
        ModifyField{
            name: "t"
            read: false
            write: false
        }
    }
    
    ObjectType{
        name: "QChildEvent"
        ModifyField{
            name: "c"
            read: false
            write: false
        }
        ModifyFunction{
            signature: "operator=(const QChildEvent &)"
            rename: "set"
            ModifyArgument{
                index: "return"
                replaceType: "void"
            }
        }
        ModifyFunction{
            signature: "clone()const"
            ModifyArgument{
                index: "return"
                DefineOwnership{
                    codeClass: CodeClass.Native
                    ownership: Ownership.Java
                }
                DefineOwnership{
                    codeClass: CodeClass.Shell
                    ownership: Ownership.Cpp
                }
            }
            since: 6
        }
    }
    
    ObjectType{
        name: "QTimerEvent"
        ModifyField{
            name: "id"
            read: false
            write: true
            rename: "timerId"
        }
        ModifyFunction{
            signature: "operator=(const QTimerEvent &)"
            rename: "set"
            ModifyArgument{
                index: "return"
                replaceType: "void"
            }
        }
        ModifyFunction{
            signature: "clone()const"
            ModifyArgument{
                index: "return"
                DefineOwnership{
                    codeClass: CodeClass.Native
                    ownership: Ownership.Java
                }
                DefineOwnership{
                    codeClass: CodeClass.Shell
                    ownership: Ownership.Cpp
                }
            }
            since: 6
        }
    }
    
    ObjectType{
        name: "QDeferredDeleteEvent"
        javaName: "QDeferredDisposeEvent"
        ModifyFunction{
            signature: "operator=(const QDeferredDeleteEvent &)"
            rename: "set"
            ModifyArgument{
                index: "return"
                replaceType: "void"
            }
        }
        ModifyFunction{
            signature: "clone()const"
            ModifyArgument{
                index: "return"
                DefineOwnership{
                    codeClass: CodeClass.Native
                    ownership: Ownership.Java
                }
                DefineOwnership{
                    codeClass: CodeClass.Shell
                    ownership: Ownership.Cpp
                }
            }
            since: 6
        }
    }
    
    ObjectType{
        name: "QDynamicPropertyChangeEvent"
        ModifyFunction{
            signature: "operator=(const QDynamicPropertyChangeEvent &)"
            rename: "set"
            ModifyArgument{
                index: "return"
                replaceType: "void"
            }
        }
        ModifyFunction{
            signature: "clone()const"
            ModifyArgument{
                index: "return"
                DefineOwnership{
                    codeClass: CodeClass.Native
                    ownership: Ownership.Java
                }
                DefineOwnership{
                    codeClass: CodeClass.Shell
                    ownership: Ownership.Cpp
                }
            }
            since: 6
        }
    }
    
    ObjectType{
        name: "QDataStream"
        ExtraIncludes{
            Include{
                fileName: "QtCore/QFloat16"
                location: Include.Global
            }
        }
        ModifyFunction{
            signature: "QDataStream(QIODevice*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcDevice"
                    action: ReferenceCount.Set
                }
            }
        }
        ModifyFunction{
            signature: "setDevice(QIODevice*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcDevice"
                    action: ReferenceCount.Set
                }
            }
        }
        ModifyFunction{
            signature: "operator<<(char)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "operator<<(std::nullptr_t)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator<<(unsigned int)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator<<(unsigned long long)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator<<(unsigned char)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator<<(char16_t)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "operator<<(char32_t)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "operator>>(char&)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "operator>>(uint&)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator>>(unsigned char&)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator>>(char16_t&)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "operator>>(char32_t&)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "operator>>(unsigned long long&)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator>>(std::nullptr_t&)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "readBytes(char&*,uint&)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "writeBytes(const char*,uint)"
            remove: RemoveFlag.All
        }
        Import{
            template: "Stream"
        }
        ModifyFunction{
            signature: "operator<<(unsigned short)"
            Rename{
                to: "writeChar"
            }
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "char"
                }
            }
        }
        ModifyFunction{
            signature: "operator>>(unsigned short&)"
            Rename{
                to: "readChar"
            }
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "char"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "Q_UNUSED(__qt_return_value)\n"+
                                  "%out = __qt_%1;"}
                }
            }
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "unsigned short %out = 0;"}
                }
            }
        }
        ModifyFunction{
            signature: "operator<<(qfloat16)"
            Rename{
                to: "writeFloat16"
            }
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "operator>>(qfloat16&)"
            Rename{
                to: "readFloat16"
            }
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "float"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "Q_UNUSED(__qt_return_value)\n"+
                                  "%out = __qt_%1;"}
                }
            }
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "qfloat16 %out;"}
                }
            }
        }
        ModifyFunction{
            signature: "operator<<(bool)"
            Rename{
                to: "writeBoolean"
            }
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "operator>>(bool&)"
            Rename{
                to: "readBoolean"
            }
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "boolean"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "Q_UNUSED(__qt_return_value)\n"+
                                  "%out = __qt_%1;"}
                }
            }
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "bool %out = false;"}
                }
            }
        }
        ModifyFunction{
            signature: "operator<<(signed char)"
            Rename{
                to: "writeByte"
            }
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "operator<<(int)"
            Rename{
                to: "writeInt"
            }
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "operator<<(short)"
            Rename{
                to: "writeShort"
            }
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "operator>>(int&)"
            Rename{
                to: "readInt"
            }
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "int"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "Q_UNUSED(__qt_return_value)\n"+
                                  "%out = __qt_%1;"}
                }
            }
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "int %out = 0;"}
                }
            }
        }
        ModifyFunction{
            signature: "operator>>(signed char&)"
            Rename{
                to: "readByte"
            }
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "byte"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "Q_UNUSED(__qt_return_value)\n"+
                                  "%out = __qt_%1;"}
                }
            }
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "signed char %out = 0;"}
                }
            }
        }
        ModifyFunction{
            signature: "operator>>(short&)"
            Rename{
                to: "readShort"
            }
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "short"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "Q_UNUSED(__qt_return_value)\n"+
                                  "%out = __qt_%1;"}
                }
            }
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "short %out = 0;"}
                }
            }
        }
        ModifyFunction{
            signature: "operator>>(char &*)"
            Rename{
                to: "readString"
            }
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "Q_UNUSED(__qt_return_value)\n"+
                                  "if(__qt_%1){\n"+
                                  "    %out = %env->NewStringUTF(__qt_%1);\n"+
                                  "    delete[] __qt_%1;\n"+
                                  "}"}
                }
            }
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "char* %out = nullptr;"}
                }
            }
        }
        ModifyFunction{
            signature: "operator<<(const char*)"
            Rename{
                to: "writeString"
            }
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        ModifyFunction{
            signature: "unsetDevice()"
            InjectCode{
                position: Position.End
                Text{content: "__rcDevice = null;"}
            }
            until: 5
        }
        ModifyFunction{
            signature: "QDataStream(QByteArray*,QFlags<QIODevice::OpenModeFlag>)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
                NoNullPointer{
                }
                ReferenceCount{
                    variableName: "__rcDevice"
                    action: ReferenceCount.Set
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QByteArray* %out = qtjambi_cast<QByteArray*>(%env, %in);"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "QDataStream(QByteArray*,QFlags<QIODeviceBase::OpenModeFlag>)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
                NoNullPointer{
                }
                ReferenceCount{
                    variableName: "__rcDevice"
                    action: ReferenceCount.Set
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QByteArray* %out = qtjambi_cast<QByteArray*>(%env, %in);"}
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "readRawData(char*,int)"
            rename: "readBytes"
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
            }
        }
        ModifyFunction{
            signature: "writeRawData(const char*,int)"
            rename: "writeBytes"
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
            }
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QDataStream___"
                quoteBeforeLine: "}// class"
            }
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QDataStream_5__"
                quoteBeforeLine: "}// class"
                until: 5
            }
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QDataStream_6__"
                quoteBeforeLine: "}// class"
                since: 6
            }
        }
    }
    
    ObjectType{
        name: "QTextStream"
        implementing: "java.lang.Appendable"
        ModifyFunction{
            signature: "QTextStream(const QByteArray&, QFlags<QIODevice::OpenModeFlag>)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "QTextStream(const QByteArray&, QFlags<QIODeviceBase::OpenModeFlag>)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "QTextStream(QString*,QFlags<QIODevice::OpenModeFlag>)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "QTextStream(QString*,QFlags<QIODeviceBase::OpenModeFlag>)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "device() const"
            rename: "device_private"
            access: Modification.Private
        }
        ModifyFunction{
            signature: "readLineInto(QString *, long long)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator<<(QLatin1String)"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "operator<<(QLatin1StringView)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "operator<<(char16_t)"
            remove: RemoveFlag.All
            since: [6, 3]
        }
        ModifyFunction{
            signature: "operator>>(char16_t&)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "operator<<(const QStringRef &)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "operator<<(QStringView)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator<<(signed long)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator<<(unsigned int)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator>>(ulong&)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator>>(signed long&)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator>>(unsigned long long&)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator>>(unsigned short&)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator<<(unsigned long)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator<<(const void*)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator<<(unsigned long long)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator<<(unsigned short)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator>>(uint&)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "setString(QString*,QFlags<QIODevice::OpenModeFlag>)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "setString(QString*,QFlags<QIODeviceBase::OpenModeFlag>)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "string()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "reset()"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "flush()"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "setCodec(QTextCodec *)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcCodec"
                    action: ReferenceCount.Set
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "QTextStream(QIODevice *)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcDevice"
                    action: ReferenceCount.Set
                }
            }
        }
        ModifyFunction{
            signature: "setDevice(QIODevice *)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcDevice"
                    action: ReferenceCount.Set
                }
            }
        }
        Import{
            template: "Stream"
        }
        ModifyFunction{
            signature: "operator<<(char)"
            Rename{
                to: "writeByte"
            }
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "operator<<(signed int)"
            Rename{
                to: "writeInt"
            }
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "operator<<(signed short)"
            Rename{
                to: "writeShort"
            }
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "operator<<(QChar)"
            Rename{
                to: "writeChar"
            }
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "operator>>(QChar&)"
            Rename{
                to: "readChar"
            }
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "char"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "Q_UNUSED(__qt_return_value)\n"+
                                  "%out = qtjambi_cast<jchar>(%env, __qt_%1);"}
                }
            }
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QChar %out;"}
                }
            }
        }
        ModifyFunction{
            signature: "operator>>(signed int&)"
            Rename{
                to: "readInt"
            }
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "int"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "Q_UNUSED(__qt_return_value)\n"+
                                  "%out = __qt_%1;"}
                }
            }
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "int %out = 0;"}
                }
            }
        }
        ModifyFunction{
            signature: "operator>>(char&)"
            Rename{
                to: "readByte"
            }
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "byte"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "Q_UNUSED(__qt_return_value)\n"+
                                  "%out = __qt_%1;"}
                }
            }
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "char %out = 0;"}
                }
            }
        }
        ModifyFunction{
            signature: "operator>>(signed short&)"
            Rename{
                to: "readShort"
            }
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "short"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "Q_UNUSED(__qt_return_value)\n"+
                                  "%out = __qt_%1;"}
                }
            }
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "short %out = 0;"}
                }
            }
        }
        ModifyFunction{
            signature: "operator>>(QByteArray&)"
            Rename{
                to: "readBytes"
            }
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "Q_UNUSED(__qt_return_value)\n"+
                                  "%out = qtjambi_cast<jobject>(%env, __qt_%1);"}
                }
            }
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QByteArray %out;"}
                }
            }
        }
        ModifyFunction{
            signature: "operator<<(const QByteArray&)"
            Rename{
                to: "writeBytes"
            }
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "operator>>(QString&)"
            Rename{
                to: "readQString"
            }
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "io.qt.core.QString"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "Q_UNUSED(__qt_return_value)\n"+
                                  "%out = QtJambiAPI::convertQStringToJavaObject(%env, __qt_%1);"}
                }
            }
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QString %out;"}
                }
            }
        }
        ModifyFunction{
            signature: "operator>>(char*)"
            Rename{
                to: "readString"
            }
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "Q_UNUSED(__qt_return_value)\n"+
                                  "%out = qtjambi_cast<jstring>(%env, __qt_%1);"}
                }
            }
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QString %out;"}
                }
            }
        }
        ModifyFunction{
            signature: "operator<<(const char*)"
            Rename{
                to: "writeString"
            }
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        ModifyFunction{
            signature: "operator<<(QString)"
            Rename{
                to: "writeString"
            }
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.CharSequence"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QString %out = qtjambi_cast<QString>(%env, %1);"}
                }
            }
        }
        ModifyFunction{
            signature: "QTextStream(QByteArray*,QFlags<QIODevice::OpenModeFlag>)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcDevice"
                    action: ReferenceCount.Set
                }
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
                NoNullPointer{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QByteArray* %out = qtjambi_cast<QByteArray*>(%env, %in);"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "QTextStream(QByteArray*,QFlags<QIODeviceBase::OpenModeFlag>)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcDevice"
                    action: ReferenceCount.Set
                }
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
                NoNullPointer{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QByteArray* %out = qtjambi_cast<QByteArray*>(%env, %in);"}
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "setCodec(const char*)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
            until: 5
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QTextStream___"
                quoteBeforeLine: "}// class"
            }
        }
    }
    
    ObjectType{
        name: "QPromise"
        disableNativeIdUsage: true
        template: true
        TemplateArguments{
            arguments: ["QVariant"]
        }
        since: 6
    }
    
    ObjectType{
        name: "QPromise<QVariant>"
        isGeneric: true
        targetType: "final class"
        disableNativeIdUsage: true
        generate: false
        since: 6
    }
    
    ValueType{
        name: "QFuture"
        disableNativeIdUsage: true
        template: true
        TemplateArguments{
            arguments: ["QVariant"]
        }
    }
    
    ValueType{
        name: "QFuture<QVariant>"
        isGeneric: true
        targetType: "final class"
        disableNativeIdUsage: true
        generate: false
    }
    
    NamespaceType{
        name: "QtFuture"
        ExtraIncludes{
            Include{
                fileName: "QtCore/QFuture"
                location: Include.Global
            }
            Include{
                fileName: "qfuture_impl.h"
                suppressed: true
                location: Include.Global
            }
            Include{
                fileName: "QtCore/qfuture_impl.h"
                suppressed: true
                location: Include.Global
            }
        }
        InjectCode{
            target: CodeClass.Java
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QtFuture___"
                quoteBeforeLine: "}// class"
            }
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QtFuture_6_1__"
                quoteBeforeLine: "}// class"
                since: [6, 1]
            }
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QtFuture_6_3__"
                quoteBeforeLine: "}// class"
                since: [6, 3]
            }
        }
        since: 6
    }
    
    EnumType{
        name: "QtFuture::Launch"
        since: 6
    }
    
    EnumType{
        name: "QFutureInterfaceBase::State"
        extensible: true
    }
    
    FunctionalType{
        name: "QFutureInterfaceBase::Continuation"
        generate: false
        using: "std::function<void(const QFutureInterfaceBase&)>"
    }
    
    ValueType{
        name: "QFutureInterfaceBase"
        ExtraIncludes{
            Include{
                fileName: "utils_p.h"
                location: Include.Local
            }
            Include{
                fileName: "QtJambi/CoreAPI"
                location: Include.Global
            }
            Include{
                fileName: "QtJambi/JObjectWrapper"
                location: Include.Global
            }
        }
        ModifyFunction{
            // in Qt6.4.0 this was removed but re-added in 6.4.1 leading to undefined symbol exception
            signature: "cleanContinuation()"
            proxyCall: "CoreAPI::cleanContinuation"
            since: 6.4
            until: 6.4
        }
        ModifyFunction{
            signature: "operator=(const QFutureInterfaceBase&)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "waitForFinished()"
            InjectCode{
                target: CodeClass.Native
                position: Position.Beginning
                Text{content: "CoreAPI::invokeAndCatch(%env, __qt_this, [](void* ptr){\n"+
                              "QFutureInterfaceBase *__qt_this = reinterpret_cast<QFutureInterfaceBase *>(ptr);"}
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.End
                Text{content: "});"}
            }
        }
        ModifyFunction{
            signature: "setContinuation(std::function<void(const QFutureInterfaceBase&)>)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.util.function.Consumer<QFutureInterfaceBase>"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    InsertTemplate{
                        name: "core.comsumer.function"
                        Replace{
                            from: "%TYPE"
                            to: "const QFutureInterfaceBase &"
                        }
                    }
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "setThreadPool(QThreadPool*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcThreadPool"
                    action: ReferenceCount.Set
                }
            }
        }
        ModifyFunction{
            signature: "setRunnable(QRunnable*)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "io.qt.core.QRunnable"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QRunnable* %out = qtjambi_cast<QRunnable*>(%env, %in);\n"+
                                  "if(%out && %out->autoDelete())\n"+
                                  "    QtJambiAPI::setCppOwnership(%env, %in);"}
                }
                ReferenceCount{
                    variableName: "__rcRunnable"
                    action: ReferenceCount.Set
                }
            }
        }
        ModifyFunction{
            signature: "reportFinished()"
            access: Modification.NonFinal
        }
        InjectCode{
            target: CodeClass.Java
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QFutureInterfaceBase___"
                quoteBeforeLine: "}// class"
            }
        }
        InjectCode{
            target: CodeClass.Native
            Text{content: "const std::type_info& typeid_QFutureInterfaceBase_shell(){\n"+
                          "    return typeid(QFutureInterfaceBase_shell);\n"+
                          "}"}
        }
    }
    
    ObjectType{
        name: "QFutureWatcherBase"
        ExtraIncludes{
            Include{
                fileName: "QtJambi/CoreAPI"
                location: Include.Global
            }
        }
        ModifyFunction{
            signature: "waitForFinished()"
            InjectCode{
                target: CodeClass.Native
                position: Position.Beginning
                Text{content: "CoreAPI::invokeAndCatch(%env, __qt_this, [](void* ptr){\n"+
                              "QFutureWatcherBase *__qt_this = reinterpret_cast<QFutureWatcherBase *>(ptr);"}
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.End
                Text{content: "});"}
            }
        }
        ModifyFunction{
            signature: "futureInterface()"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "io.qt.core.QFutureInterfaceBase"
                }
                NoNullPointer{
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "QFutureInterfaceBase* %out = qtjambi_cast<QFutureInterfaceBase*>(%env, %in);"}
                }
            }
        }
        ModifyFunction{
            signature: "futureInterface() const"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "io.qt.core.QFutureInterfaceBase"
                }
                NoNullPointer{
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "const QFutureInterfaceBase* %out = qtjambi_cast<const QFutureInterfaceBase*>(%env, %in);"}
                }
            }
        }
    }
    
    ObjectType{
        name: "QFutureWatcher"
        disableNativeIdUsage: true
        template: true
        TemplateArguments{
            arguments: ["QVariant"]
        }
    }
    
    ObjectType{
        name: "QFutureWatcher<QVariant>"
        isGeneric: true
        disableNativeIdUsage: true
        generate: false
    }
    
    ValueType{
        name: "QFutureInterface"
        disableNativeIdUsage: true
        template: true
        TemplateArguments{
            arguments: ["QVariant"]
        }
    }
    
    ValueType{
        name: "QFutureInterface<QVariant>"
        isGeneric: true
        targetType: "final class"
        disableNativeIdUsage: true
        generate: false
    }
    
    ObjectType{
        name: "QThreadPool"
        ExtraIncludes{
            Include{
                fileName: "QtJambi/JObjectWrapper"
                location: Include.Global
            }
            Include{
                fileName: "utils_p.h"
                location: Include.Global
            }
        }
        ModifyFunction{
            signature: "start(QRunnable *, int)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.Runnable"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QRunnable* %out = nullptr;\n"+
                                  "if(Java::QtCore::QRunnable::isInstanceOf(%env, %in)){\n"+
                                  "    %out = qtjambi_cast<QRunnable*>(%env, %in);\n"+
                                  "    QtJambiAPI::setCppOwnership(%env, %in);\n"+
                                  "}else{\n"+
                                  "    JObjectWrapper __wrapper_%in(%env, %in);\n"+
                                  "    %out = QRunnable::create([__wrapper_%in](){\n"+
                                  "            QTJAMBI_TRY_ANY{\n"+
                                  "                if(JniEnvironment env{300}){\n"+
                                  "                    QtJambiExceptionInhibitor __exnHandler;\n"+
                                  "                    jobject object = env->NewLocalRef(__wrapper_runnable0.object());\n"+
                                  "                    QTJAMBI_TRY{\n"+
                                  "                        Java::Runtime::Runnable::run(env, object);\n"+
                                  "                    }QTJAMBI_CATCH(const JavaException& exn){\n"+
                                  "                        __exnHandler.handle(env, exn, \"QRunnable::run()\");\n"+
                                  "                    }QTJAMBI_TRY_END\n"+
                                  "                }\n"+
                                  "            }QTJAMBI_CATCH_ANY{}QTJAMBI_TRY_END\n"+
                                  "        });\n"+
                                  "}"}
                }
            }
        }
        ModifyFunction{
            signature: "startOnReservedThread(QRunnable *)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.Runnable"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QRunnable* %out = nullptr;\n"+
                                  "if(Java::QtCore::QRunnable::isInstanceOf(%env, %in)){\n"+
                                  "    %out = qtjambi_cast<QRunnable*>(%env, %in);\n"+
                                  "    QtJambiAPI::setCppOwnership(%env, %in);\n"+
                                  "}else{\n"+
                                  "    JObjectWrapper __wrapper_%in(%env, %in);\n"+
                                  "    %out = QRunnable::create([__wrapper_%in](){\n"+
                                  "            QTJAMBI_TRY_ANY{\n"+
                                  "                if(JniEnvironment env{300}){\n"+
                                  "                    QtJambiExceptionInhibitor __exnHandler;\n"+
                                  "                    jobject object = env->NewLocalRef(__wrapper_runnable0.object());\n"+
                                  "                    QTJAMBI_TRY{\n"+
                                  "                        Java::Runtime::Runnable::run(env, object);\n"+
                                  "                    }QTJAMBI_CATCH(const JavaException& exn){\n"+
                                  "                        __exnHandler.handle(env, exn, \"QRunnable::run()\");\n"+
                                  "                    }QTJAMBI_TRY_END\n"+
                                  "                }\n"+
                                  "            }QTJAMBI_CATCH_ANY{}QTJAMBI_TRY_END\n"+
                                  "        });\n"+
                                  "}"}
                }
            }
            since: [6, 3]
        }
        ModifyFunction{
            signature: "tryStart(QRunnable *)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.Runnable"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QRunnable* %out = nullptr;\n"+
                                  "QtJambiScope scope;\n"+
                                  "if(Java::QtCore::QRunnable::isInstanceOf(%env, %in)){\n"+
                                  "    %out = qtjambi_cast<QRunnable*>(%env, %in);\n"+
                                  "    QtJambiAPI::setCppOwnership(%env, %in);\n"+
                                  "}else{\n"+
                                  "    JObjectWrapper __wrapper_%in(%env, %in);\n"+
                                  "    %out = QRunnable::create([__wrapper_%in](){\n"+
                                  "            QTJAMBI_TRY_ANY{\n"+
                                  "                if(JniEnvironment env{300}){\n"+
                                  "                    QtJambiExceptionInhibitor __exnHandler;\n"+
                                  "                    jobject object = env->NewLocalRef(__wrapper_runnable0.object());\n"+
                                  "                    QTJAMBI_TRY{\n"+
                                  "                        Java::Runtime::Runnable::run(env, object);\n"+
                                  "                    }QTJAMBI_CATCH(const JavaException& exn){\n"+
                                  "                        __exnHandler.handle(env, exn, \"QRunnable::run()\");\n"+
                                  "                    }QTJAMBI_TRY_END\n"+
                                  "                }\n"+
                                  "            }QTJAMBI_CATCH_ANY{}QTJAMBI_TRY_END\n"+
                                  "        });\n"+
                                  "    scope.addFinalAction([&](){\n"+
                                  "        if(!__java_return_value)\n"+
                                  "            delete %out;\n"+
                                  "        });\n"+
                                  "}"}
                }
            }
        }
    }
    
    InterfaceType{
        name: "QRunnable"
        implementing: "Runnable"
        ModifyFunction{
            signature: "run()"
            noExcept: true
            blockExceptions: true
        }
        InjectCode{
            target: CodeClass.JavaInterface
            Text{content: "public static QRunnable of(Runnable runnable) {\n"+
                          "    if(runnable instanceof QRunnable) {\n"+
                          "        return (QRunnable)runnable;\n"+
                          "    }else if(runnable==null){\n"+
                          "        return null;\n"+
                          "    }else {\n"+
                          "        return runnable::run;\n"+
                          "    }\n"+
                          "}"}
        }
    }
    
    
    ValueType{
        name: "QXmlStreamAttribute"
        ModifyFunction{
            signature: "operator=(QXmlStreamAttribute)"
            remove: RemoveFlag.All
            until: 5
        }
        CustomConstructor{
            type: CustomConstructor.Copy
            until: 5
            Text{content: "if(copy->namespaceUri().isEmpty())\n"+
                          "    new(placement) QXmlStreamAttribute(copy->qualifiedName().string() ? *copy->qualifiedName().string() : QString(),\n"+
                          "                                       copy->value().string() ? *copy->value().string() : QString());\n"+
                          "else\n"+
                          "    new(placement) QXmlStreamAttribute(copy->namespaceUri().string() ? *copy->namespaceUri().string() : QString(),\n"+
                          "                                       copy->name().string() ? *copy->name().string() : QString(),\n"+
                          "                                       copy->value().string() ? *copy->value().string() : QString());"}
        }
        CustomConstructor{
            type: CustomConstructor.Copy
            since: 6
            Text{content: "if(copy->namespaceUri().isEmpty())\n"+
                          "    new(placement) QXmlStreamAttribute(copy->qualifiedName().toString(), copy->value().toString());\n"+
                          "else\n"+
                          "    new(placement) QXmlStreamAttribute(copy->namespaceUri().toString(),\n"+
                          "                                       copy->name().toString(),\n"+
                          "                                       copy->value().toString());"}
        }
    }
    
    ValueType{
        name: "QXmlStreamAttributes"
        ModifyFunction{
            signature: "value(const QString &, const QLatin1String &)const"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "value(const QString &, const QLatin1StringView &)const"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "value(QLatin1String, QLatin1String)const"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "value(QLatin1StringView, QLatin1StringView)const"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "value(QLatin1String)const"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "value(QLatin1StringView)const"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "hasAttribute(QLatin1String)const"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "hasAttribute(QLatin1StringView)const"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QXmlStreamAttributes___"
                quoteBeforeLine: "}// class"
            }
        }
        InjectCode{
            target: CodeClass.Native
            position: Position.Beginning
            Text{content: "bool operator<(const QXmlStreamAttribute& lhs, const QXmlStreamAttribute& rhs)\n"+
                          "{\n"+
                          "    return qHash(lhs) < qHash(rhs);\n"+
                          "}\n"+
                          "namespace QtJambiPrivate{\n"+
                          "    template<>\n"+
                          "    struct supports_less_than<QXmlStreamAttributes> : std::false_type{};\n"+
                          "    template<>\n"+
                          "    struct supports_stream_operators<QXmlStreamAttributes> : std::false_type{};\n"+
                          "    template<>\n"+
                          "    struct supports_debugstream<QXmlStreamAttributes> : std::false_type{};\n"+
                          "}"}
        }
    }
    
    ValueType{
        name: "QXmlStreamNamespaceDeclaration"
        ModifyFunction{
            signature: "operator=(QXmlStreamNamespaceDeclaration)"
            remove: RemoveFlag.All
            until: 5
        }
    }
    
    ValueType{
        name: "QXmlStreamNotationDeclaration"
        ModifyFunction{
            signature: "operator=(QXmlStreamNotationDeclaration)"
            remove: RemoveFlag.All
            until: 5
        }
    }
    
    ValueType{
        name: "QXmlStreamEntityDeclaration"
        ModifyFunction{
            signature: "operator=(QXmlStreamEntityDeclaration)"
            remove: RemoveFlag.All
            until: 5
        }
    }
    
    ObjectType{
        name: "QXmlStreamReader"
        ModifyFunction{
            signature: "QXmlStreamReader(const char*)"
            remove: RemoveFlag.All
            until: [6,4]
        }
        ModifyFunction{
            signature: "addData(const char*)"
            remove: RemoveFlag.All
            until: [6,4]
        }
        ModifyFunction{
            signature: "setEntityResolver(QXmlStreamEntityResolver*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcEntityResolver"
                    action: ReferenceCount.Set
                }
            }
        }
        ModifyFunction{
            signature: "setDevice(QIODevice*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcDevice"
                    action: ReferenceCount.Set
                }
            }
        }
        ModifyFunction{
            signature: "QXmlStreamReader(QIODevice*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcDevice"
                    action: ReferenceCount.Set
                }
            }
        }
        ModifyFunction{
            signature: "clear()"
            InjectCode{
                target: CodeClass.Java
                position: Position.End
                Text{content: "__rcDevice = null; // clear() call removes device from stream"}
            }
        }
    }
    
    ObjectType{
        name: "QXmlStreamWriter"
        ModifyFunction{
            signature: "QXmlStreamWriter(QString *)"
            Remove{
            }
        }
        ModifyFunction{
            signature: "QXmlStreamWriter(QIODevice*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcDevice"
                    action: ReferenceCount.Set
                }
            }
        }
        ModifyFunction{
            signature: "QXmlStreamWriter(QByteArray *)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
                NoNullPointer{
                }
                ReferenceCount{
                    variableName: "__rcDevice"
                    action: ReferenceCount.Set
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QByteArray* %out = qtjambi_cast<QByteArray*>(%env, %in);"}
                }
            }
        }
        ModifyFunction{
            signature: "setCodec(const char *)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "setCodec(QTextCodec*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcCodec"
                    action: ReferenceCount.Set
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "setDevice(QIODevice*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcDevice"
                    action: ReferenceCount.Set
                }
            }
        }
    }
    
    EnumType{
        name: "QLockFile::LockError"
    }
    
    ObjectType{
        name: "QLockFile"
        ExtraIncludes{
            Include{
                fileName: "utils_p.h"
                location: Include.Local
            }
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QLockFile__"
                quoteBeforeLine: "}// class"
            }
        }
        ModifyFunction{
            signature: "getLockInfo(long long *, QString *, QString *) const"
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "long long pid(0);\n"+
                                  "long long* %out = &pid;"}
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QString hostname;\n"+
                                  "QString* %out = &hostname;"}
                }
            }
            ModifyArgument{
                index: 3
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QString appname;\n"+
                                  "QString* %out = &appname;"}
                }
            }
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "io.qt.core.QLockFile$LockInfo"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = %in ? Java::QtCore::QLockFile$LockInfo::newInstance(%env, jlong(pid), qtjambi_cast<jstring>(%env, hostname), qtjambi_cast<jstring>(%env, appname)) : nullptr;"}
                }
            }
        }
    }
    
    ObjectType{
        name: "QMessageAuthenticationCode"
        ModifyFunction{
            signature: "addData(QIODevice*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    action: ReferenceCount.Ignore
                }
            }
        }
        ModifyFunction{
            signature: "addData(const char *, int)"
            ModifyArgument{
                index: 1
                ArrayType{
                    asBuffer: true
                    lengthParameter: 2
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "addData(const char *, qsizetype)"
            ModifyArgument{
                index: 1
                ArrayType{
                    asBuffer: true
                    lengthParameter: 2
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
            }
            since: 6
        }
        InjectCode{
            Text{content: "@io.qt.QtUninvokable\n"+
                          "public final void addData(byte[] array){\n"+
                          "    addData(java.nio.ByteBuffer.wrap(array));\n"+
                          "}"}
        }
    }
    
    EnumType{
        name: "QAbstractFileEngine::Extension"
        packageName: "io.qt.core.internal"
        extensible: true
    }
    
    EnumType{
        name: "QAbstractFileEngine::FileFlag"
        packageName: "io.qt.core.internal"
        flags: "QAbstractFileEngine::FileFlags"
    }
    
    EnumType{
        name: "QAbstractFileEngine::FileName"
        packageName: "io.qt.core.internal"
    }
    
    EnumType{
        name: "QAbstractFileEngine::FileOwner"
        packageName: "io.qt.core.internal"
    }
    
    EnumType{
        name: "QAbstractFileEngine::FileTime"
        packageName: "io.qt.core.internal"
    }
    
    EnumType{
        name: "QAbstractFileEngineIterator::EntryInfoType"
        packageName: "io.qt.core.internal"
        extensible: true
    }
    
    ObjectType{
        name: "QAbstractFileEngineIterator"
        packageName: "io.qt.core.internal"
        implementing: "Iterable<String>, java.util.Iterator<String>"
        InjectCode{
            InsertTemplate{
                name: "core.self_iterator"
                Replace{
                    from: "%ELEMENT_TYPE"
                    to: "String"
                }
            }
        }
    }
    
    ObjectType{
        name: "QAbstractFileEngineHandler"
        packageName: "io.qt.core.internal"
        ModifyFunction{
            signature: "create(const QString &) const"
            ModifyArgument{
                index: "return"
                DefineOwnership{
                    codeClass: CodeClass.Shell
                    ownership: Ownership.Cpp
                }
                DefineOwnership{
                    codeClass: CodeClass.Native
                    ownership: Ownership.Java
                }
            }
        }
    }
    
    ObjectType{
        name: "QAbstractFileEngine"
        packageName: "io.qt.core.internal"
        ModifyFunction{
            signature: "create(const QString &)"
            ModifyArgument{
                index: "return"
                DefineOwnership{
                    codeClass: CodeClass.Shell
                    ownership: Ownership.Cpp
                }
                DefineOwnership{
                    codeClass: CodeClass.Native
                    ownership: Ownership.Java
                }
            }
        }
        ModifyFunction{
            signature: "cloneTo(QAbstractFileEngine *)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    action: ReferenceCount.Ignore
                }
            }
        }
        ModifyFunction{
            signature: "beginEntryList(QFlags<QDir::Filter>,const QStringList)"
            ModifyArgument{
                index: "return"
                DefineOwnership{
                    codeClass: CodeClass.Shell
                    ownership: Ownership.Cpp
                }
                DefineOwnership{
                    codeClass: CodeClass.Native
                    ownership: Ownership.Java
                }
            }
        }
        ModifyFunction{
            signature: "beginEntryList(QFlags<QDir::Filter>,const QStringList)"
            ModifyArgument{
                index: "return"
                DefineOwnership{
                    codeClass: CodeClass.Shell
                    ownership: Ownership.Cpp
                }
                DefineOwnership{
                    codeClass: CodeClass.Native
                    ownership: Ownership.Java
                }
            }
        }
        ModifyFunction{
            signature: "endEntryList()"
            ModifyArgument{
                index: "return"
                DefineOwnership{
                    codeClass: CodeClass.Shell
                    ownership: Ownership.Cpp
                }
                DefineOwnership{
                    codeClass: CodeClass.Native
                    ownership: Ownership.Java
                }
            }
        }
        ExtraIncludes{
            Include{
                fileName: "QtJambi/JavaAPI"
                location: Include.Global
            }
        }
        ModifyFunction{
            signature: "cloneTo(QAbstractFileEngine*)"
            ModifyArgument{
                index: 1
                invalidateAfterUse: true
            }
        }
        ModifyFunction{
            signature: "map(long long, long long, QFileDevice::MemoryMapFlags)"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.nio.ByteBuffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = %in ? %env->NewDirectByteBuffer(%in, qMin(%2, jlong(__qt_this->size())-%1)) : nullptr;"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "map(long long, long long, QFlags<QFileDevice::MemoryMapFlag>)"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.nio.ByteBuffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = %in ? %env->NewDirectByteBuffer(%in, qMin(%2, jlong(__qt_this->size())-%1)) : nullptr;"}
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "unmap(unsigned char*)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.nio.ByteBuffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "if(!Java::Runtime::Buffer::isDirect(%env,%in)){\n"+
                                  "    JavaException::raiseIllegalArgumentException(%env, \"Direct buffer expected but given buffer is indirect.\" QTJAMBI_STACKTRACEINFO );\n"+
                                  "}\n"+
                                  "uchar* %out = %in ? reinterpret_cast<uchar*>(%env->GetDirectBufferAddress(%in)) : nullptr;"}
                }
            }
        }
        ModifyFunction{
            signature: "read(char *, long long)"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "int"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "qint64 %out = qint64(%in);\n"+
                                  "while(%2 > INT_MAX && %in == INT_MAX){\n"+
                                  "    %2 -= INT_MAX;\n"+
                                  "    %1 = &%1[INT_MAX];\n"+
                                  "    CharPointerArray %1_buffer2(%env, %1, jsize(qMin(qint64(INT_MAX), %2)));\n"+
                                  "    %in = %env->CallIntMethod(__java_this, method_id, %1_buffer2.array());\n"+
                                  "    %out += %in;\n"+
                                  "}"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jint %out = jint(%in);"}
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "byte[]"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "jbyteArray %out = qtjambi_array_cast<jbyteArray>(%env, %scope, %in, jsize(qMin(qint64(INT_MAX), %2)));"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jsize %2 = 0;\n"+
                                  "char * %out = qtjambi_array_cast<char *>(%env, %scope, jbyteArray(%in), %2);"}
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
            }
        }
        ModifyFunction{
            signature: "readLine(char *, long long)"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "int"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "qint64 %out = qint64(%in);\n"+
                                  "while(%2 > INT_MAX && %in == INT_MAX){\n"+
                                  "    %2 -= INT_MAX;\n"+
                                  "    %1 = &%1[INT_MAX];\n"+
                                  "    CharPointerArray __%1(%env, %1, jsize(qMin(qint64(INT_MAX), %2)));\n"+
                                  "    %in = %env->CallIntMethod(__java_this, method_id, __%1.array());\n"+
                                  "    %out += %in;\n"+
                                  "}"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jint %out = jint(%in);"}
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "byte[]"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "jbyteArray %out = qtjambi_array_cast<jbyteArray>(%env, %scope, %in, jsize(qMin(qint64(INT_MAX), %2)));"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jsize %2 = 0;\n"+
                                  "char * %out = qtjambi_array_cast<char *>(%env, %scope, jbyteArray(%in), %2);"}
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
            }
        }
        ModifyFunction{
            signature: "write(const char *, long long)"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "int"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "qint64 %out = qint64(%in);\n"+
                                  "while(%2 > INT_MAX && %in == INT_MAX){\n"+
                                  "    %2 -= INT_MAX;\n"+
                                  "    %1 = &%1[INT_MAX];\n"+
                                  "    j%2 = jsize(qMin(qint64(INT_MAX), %2));\n"+
                                  "    ConstCharPointerArray __%1(%env, %1, j%2);\n"+
                                  "    %in = %env->CallIntMethod(__java_this, method_id, __%1.array());\n"+
                                  "    %out += %in;\n"+
                                  "}"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jint %out = jint(%in);"}
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "byte[]"
                }
                ConversionRule{
                    codeClass: CodeClass.Shell
                    Text{content: "jsize j%2 = jsize(qMin(qint64(INT_MAX), %2));\n"+
                                  "jbyteArray %out = qtjambi_array_cast<jbyteArray>(%env, %scope, %in, j%2);"}
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jsize %2 = 0;\n"+
                                  "char * %out = qtjambi_array_cast<char *>(%env, %scope, jbyteArray(%in), %2);"}
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
            }
        }
    }
    
    ObjectType{
        name: "QFSFileEngine"
        packageName: "io.qt.core.internal"
    }
    
    ObjectType{
        name: "QCommandLineParser"
        ExtraIncludes{
            Include{
                fileName: "QtCore/QScopeGuard"
                location: Include.Global
            }
            Include{
                fileName: "QtJambi/CoreAPI"
                location: Include.Global
            }
        }
        ModifyFunction{
            signature: "process(const QCoreApplication &)"
            rethrowExceptions: true
            InjectCode{
                target: CodeClass.Native
                position: Position.Beginning
                Text{content: "CoreAPI::preExit();\n"+
                              "auto _qtjambi_unexit = qScopeGuard(&CoreAPI::unexit);"}
            }
        }
        ModifyFunction{
            signature: "process(QStringList)"
            rethrowExceptions: true
            InjectCode{
                target: CodeClass.Native
                position: Position.Beginning
                Text{content: "CoreAPI::preExit();\n"+
                              "auto _qtjambi_unexit = qScopeGuard(&CoreAPI::unexit);"}
            }
        }
        ModifyFunction{
            signature: "showVersion()"
            InjectCode{
                target: CodeClass.Native
                position: Position.Beginning
                Text{content: "CoreAPI::preExit();"}
            }
        }
        ModifyFunction{
            signature: "showHelp(int)"
            InjectCode{
                target: CodeClass.Native
                position: Position.Beginning
                Text{content: "CoreAPI::preExit();"}
            }
        }
    }
    
    ObjectType{
        name: "QFileSelector"
    }
    
    ValueType{
        name: "QCommandLineOption"
        CustomConstructor{
            Text{content: "if(copy){\n"+
                          "    return new(placement) QCommandLineOption(*copy);\n"+
                          "}else{\n"+
                          "    return new(placement) QCommandLineOption(QLatin1String(\" \"));\n"+
                          "}"}
        }
        CustomConstructor{
            type: CustomConstructor.Default
            Text{content: "new(placement) QCommandLineOption(QLatin1String(\" \"));"}
        }
        ModifyFunction{
            signature: "operator=(const QCommandLineOption&)"
            remove: RemoveFlag.All
        }
    }
    
    ValueType{
        name: "QCollator"
        ModifyFunction{
            signature: "operator()(const QString &, const QString &)const"
            rename: "isLessThan"
            until: [5, 13, 0]
        }
        ModifyFunction{
            signature: "operator()(const QString &, const QString &)const"
            remove: RemoveFlag.All
            since: [5, 14]
        }
        ModifyFunction{
            signature: "operator()(QStringView, QStringView)const"
            rename: "isLessThan"
            since: [5, 14]
        }
        ModifyFunction{
            signature: "operator=(const QCollator&)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "compare(const QStringRef &, const QStringRef &) const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "compare(const QString &, const QString &) const"
            remove: RemoveFlag.All
            since: [5, 14]
        }
        ModifyFunction{
            signature: "compare(const QChar *, int, const QChar *, int) const"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "compare(const QChar *, qsizetype, const QChar *, qsizetype) const"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "sortKey(const QString &) const"
        }
    }
    
    ValueType{
        name: "QCollatorSortKey"
        ModifyFunction{
            signature: "compare(QCollatorSortKey) const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator=(const QCollatorSortKey&)"
            remove: RemoveFlag.All
        }
        CustomConstructor{
            Text{content: "if(copy){\n"+
                          "    return new(placement) QCollatorSortKey(*copy);\n"+
                          "}else{\n"+
                          "    return new(placement) QCollatorSortKey(QCollator().sortKey(\"\"));\n"+
                          "}"}
        }
        CustomConstructor{
            type: CustomConstructor.Default
            Text{content: "new(placement) QCollatorSortKey(QCollator().sortKey(\"\"));"}
        }
    }
    
    ValueType{
        name: "QStorageInfo"
        ModifyFunction{
            signature: "operator=(const QStorageInfo&)"
            remove: RemoveFlag.All
        }
    }
    
    ValueType{
        name: "QOperatingSystemVersion"
        defaultSuperClass: "io.qt.QtObject"
        CustomConstructor{
            Text{content: "if(copy){\n"+
                          "    return new(placement) QOperatingSystemVersion(*copy);\n"+
                          "}else{\n"+
                          "    return new(placement) QOperatingSystemVersion(QOperatingSystemVersion::Unknown, -1);\n"+
                          "}"}
        }
        CustomConstructor{
            type: CustomConstructor.Copy
            Text{content: "new(placement) QOperatingSystemVersion(copy->type(), copy->majorVersion(), copy->minorVersion(), copy->microVersion());"}
        }
        CustomConstructor{
            type: CustomConstructor.Default
            Text{content: "new(placement) QOperatingSystemVersion(QOperatingSystemVersion::Unknown, -1);"}
        }
    }
    
    EnumType{
        name: "QOperatingSystemVersion::OSType"
    }
    
    EnumType{
        name: "QOperatingSystemVersionBase::OSType"
        generate: false
        since: [6, 3]
    }
    
    ValueType{
        name: "QOperatingSystemVersionBase"
        javaName: "QOperatingSystemVersion"
        generate: false
        since: [6, 3]
    }
    
    ObjectType{
        name: "QLibraryInfo"
        ModifyFunction{
            signature: "build()"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
    }
    
    ObjectType{
        name: "QAnimationDriver"
    }
    
    EnumType{
        name: "QDeadlineTimer::ForeverConstant"
    }
    
    ValueType{
        name: "QDeadlineTimer"
        CustomConstructor{
            Text{content: "if(copy){\n"+
                          "    QDeadlineTimer* pointer = new(placement) QDeadlineTimer(copy->timerType());\n"+
                          "    pointer->setPreciseDeadline(0, copy->deadlineNSecs(), copy->timerType());\n"+
                          "    pointer->setPreciseRemainingTime(0, copy->remainingTimeNSecs(), copy->timerType());\n"+
                          "    return pointer;\n"+
                          "}else{\n"+
                          "    return new(placement) QDeadlineTimer();\n"+
                          "}"}
        }
        CustomConstructor{
            type: CustomConstructor.Copy
            Text{content: "QDeadlineTimer* pointer = new(placement) QDeadlineTimer(copy->timerType());\n"+
                          "pointer->setPreciseDeadline(0, copy->deadlineNSecs(), copy->timerType());\n"+
                          "pointer->setPreciseRemainingTime(0, copy->remainingTimeNSecs(), copy->timerType());"}
        }
        ModifyFunction{
            signature: "operator-(QDeadlineTimer)"
            rename: "minus"
        }
        ModifyFunction{
            signature: "operator-(long long)"
            rename: "minus"
        }
        ModifyFunction{
            signature: "operator+=(long long)"
            rename: "addMSecs"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QDeadlineTimer"
                }
            }
        }
        ModifyFunction{
            signature: "operator-=(long long)"
            rename: "subtractMSecs"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QDeadlineTimer"
                }
            }
        }
    }
    
    ObjectType{
        name: "QConcatenateTablesProxyModel"
        ModifyFunction{
            signature: "addSourceModel(QAbstractItemModel*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcSourceModel"
                    action: ReferenceCount.Add
                }
            }
        }
        ModifyFunction{
            signature: "removeSourceModel(QAbstractItemModel*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcSourceModel"
                    action: ReferenceCount.Take
                }
            }
        }
        since: [5, 13]
    }
    
    ObjectType{
        name: "QTransposeProxyModel"
        ModifyFunction{
            signature: "setSourceModel(QAbstractItemModel*)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcSourceModel"
                    action: ReferenceCount.Set
                }
            }
        }
        since: [5, 13]
    }
    
    FunctionalType{
        name: "QFunctionPointer"
        generate: "no-shell"
        functionName: "invoke"
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QFunctionPointer__"
                quoteBeforeLine: "}// class"
            }
        }
    }
    
    ObjectType{
        name: "QLibrary"
        ModifyFunction{
            signature: "resolve(const char *)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        ModifyFunction{
            signature: "resolve(const QString &, const char *)"
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        ModifyFunction{
            signature: "resolve(const QString &, int, const char *)"
            ModifyArgument{
                index: 3
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        ModifyFunction{
            signature: "resolve(const QString &, const QString &, const char *)"
            ModifyArgument{
                index: 3
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
    }
    
    EnumType{
        name: "QString::SplitBehavior"
        until: [5, 13]
    }
    
    EnumType{
        name: "QString::SectionFlag"
        flags: "QString::SectionFlags"
    }
    
    ValueType{
        name: "QString"
        implementing: "Appendable, CharSequence"
        targetType: "final class"
        ModifyFunction{
            signature: "QString(const char*)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "append(const char*)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "prepend(const char*)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "QString(QLatin1StringView)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "QString(QLatin1String)"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "prepend(QStringView)"
            remove: RemoveFlag.All
            since: [5, 10]
        }
        ModifyFunction{
            signature: "prepend(QLatin1StringView)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "prepend(QLatin1String)"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "prepend(QStringRef)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "compare(QString,QStringRef,Qt::CaseSensitivity)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "compare(QStringRef,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "contains(QStringRef,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "count(QStringRef,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "endsWith(QStringRef,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "startsWith(QStringRef,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "localeAwareCompare(QStringRef)const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "localeAwareCompare(QString,QStringRef)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "arg(QString,QString)const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "arg(QString,QString,QString)const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "arg(QString,QString,QString,QString)const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "arg(QString,QString,QString,QString,QString)const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "arg(QString,QString,QString,QString,QString,QString)const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "arg(QString,QString,QString,QString,QString,QString,QString)const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "arg(QString,QString,QString,QString,QString,QString,QString,QString)const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "arg(QString,QString,QString,QString,QString,QString,QString,QString,QString)const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "contains(QRegExp)const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "append(QStringRef)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "append(QStringView)"
            remove: RemoveFlag.All
            since: [5, 10]
        }
        ModifyFunction{
            signature: "append(QLatin1StringView)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "append(QLatin1String)"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "lastIndexOf(QStringView,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "lastIndexOf(QStringView,qsizetype,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "lastIndexOf(QStringView,int,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            since: [5, 10]
            until: 5
        }
        ModifyFunction{
            signature: "indexOf(QStringView,qsizetype,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "indexOf(QStringView,int,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            since: [5, 10]
            until: 5
        }
        ModifyFunction{
            signature: "indexOf(QStringRef,int,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "startsWith(QStringView,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            since: [5, 10]
        }
        ModifyFunction{
            signature: "endsWith(QStringView,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            since: [5, 10]
        }
        ModifyFunction{
            signature: "count(QStringView,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "contains(QStringView,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            since: [5, 10]
        }
        ModifyFunction{
            signature: "compare(QStringView,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "compare(QStringView,QString,Qt::CaseSensitivity)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "compare(QString,QStringView,Qt::CaseSensitivity)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "lastIndexOf(QLatin1StringView,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "lastIndexOf(QLatin1StringView,qsizetype,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "indexOf(QLatin1StringView,qsizetype,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "startsWith(QLatin1StringView,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "endsWith(QLatin1StringView,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "contains(QLatin1StringView,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "lastIndexOf(QStringRef,int,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "lastIndexOf(QLatin1String,int,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            since: [5, 10]
            until: 5
        }
        ModifyFunction{
            signature: "lastIndexOf(QLatin1String,qsizetype,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            since: 6
            until: [6, 3]
        }
        ModifyFunction{
            signature: "lastIndexOf(QLatin1String,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            since: 6
            until: [6, 3]
        }
        ModifyFunction{
            signature: "indexOf(QLatin1String,qsizetype,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            since: 6
            until: [6, 3]
        }
        ModifyFunction{
            signature: "indexOf(QLatin1String,int,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            since: [5, 10]
            until: 5
        }
        ModifyFunction{
            signature: "startsWith(QLatin1String,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "endsWith(QLatin1String,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "contains(QLatin1String,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "compare(QLatin1StringView,QString,Qt::CaseSensitivity)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "compare(QLatin1String,QString,Qt::CaseSensitivity)"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "compare(QLatin1StringView,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "compare(QString,QLatin1StringView,Qt::CaseSensitivity)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "compare(QString,QLatin1String,Qt::CaseSensitivity)"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "compare(QLatin1String,Qt::CaseSensitivity)const"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "insert(qsizetype,QLatin1StringView)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "replace(QChar,QLatin1StringView,Qt::CaseSensitivity)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "replace(QLatin1StringView,QLatin1StringView,Qt::CaseSensitivity)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "replace(QString,QLatin1StringView,Qt::CaseSensitivity)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "replace(QLatin1StringView,QString,Qt::CaseSensitivity)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "remove(QLatin1StringView,Qt::CaseSensitivity)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "insert(qsizetype,QLatin1String)"
            remove: RemoveFlag.All
            since: 6
            until: [6, 3]
        }
        ModifyFunction{
            signature: "replace(QChar,QLatin1String,Qt::CaseSensitivity)"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "replace(QLatin1String,QLatin1String,Qt::CaseSensitivity)"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "replace(QString,QLatin1String,Qt::CaseSensitivity)"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "replace(QLatin1String,QString,Qt::CaseSensitivity)"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "remove(QLatin1String,Qt::CaseSensitivity)"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "localeAwareCompare(QStringView,QStringView)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "insert(qsizetype,QStringView)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "insert(int,QStringRef)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "insert(int,QLatin1String)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "insert(int,QStringView)"
            remove: RemoveFlag.All
            since: [5, 10]
            until: 5
        }
        ModifyFunction{
            signature: "insert(int,const char*)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "insert(qsizetype,const char*)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "indexOf(QRegExp,int)const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "lastIndexOf(QRegExp,int)const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "erase(const QChar*,const QChar*)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "number(long,int)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "number(unsigned long,int)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "number(unsigned int,int)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "number(unsigned long long,int)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "arg(long,int,int,QChar)const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "arg(unsigned long,int,int,QChar)const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "arg(unsigned long long,int,int,QChar)const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "arg(unsigned int,int,int,QChar)const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "arg(unsigned short,int,int,QChar)const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "front()"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "back()"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "end()"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "cend()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "constEnd()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "begin()"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "cbegin()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "constBegin()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "constData()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "end()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "begin()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "data()"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "data()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "localeAwareCompare(QStringView)const"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "arg(QLatin1StringView,int,QChar)const"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "arg(QLatin1String,int,QChar)const"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "arg(QStringView,int,QChar)const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "setNum(long, int)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "setNum(unsigned long long, int)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "setNum(unsigned long, int)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "setNum(unsigned int, int)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "setNum(unsigned short, int)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator=(char)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "operator+=(char)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "operator+=(QChar)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator+=(QStringRef)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "operator+=(QLatin1String)"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "operator+=(QLatin1StringView)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "operator+=(QUtf8StringView)"
            remove: RemoveFlag.All
            since: [6, 5]
        }
        ModifyFunction{
            signature: "operator+=(QStringView)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator+=(QByteArray)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator+=(QString)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator+=(const char*)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator=(QChar)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator=(QLatin1String)"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "operator=(QLatin1StringView)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "operator=(QByteArray)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator=(QString)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator=(const char*)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator>(const char16_t*)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "operator>=(const char16_t*)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "operator<=(const char16_t*)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "operator<(const char16_t*)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "operator==(const char16_t*)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "operator!=(const char16_t*)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "operator[](uint)const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "operator[](qsizetype)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "operator[](int)const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "operator[](qsizetype)const"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "operator<(const char*)const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator<(std::nullptr_t)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "operator<=(std::nullptr_t)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "operator>=(std::nullptr_t)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "operator>(std::nullptr_t)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "operator==(std::nullptr_t)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "operator==(const char*)const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator!=(const char*)const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator>(const char*)const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator>=(const char*)const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator<=(const char*)const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator<(QLatin1String)const"
            remove: RemoveFlag.All
            until: [5, 10]
        }
        ModifyFunction{
            signature: "operator<(QLatin1String)"
            remove: RemoveFlag.All
            since: 6
            until: [6, 3]
        }
        ModifyFunction{
            signature: "operator<(QLatin1StringView)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "operator<=(QLatin1String)"
            remove: RemoveFlag.All
            since: 6
            until: [6, 3]
        }
        ModifyFunction{
            signature: "operator<=(QLatin1StringView)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "operator>(QLatin1String)"
            remove: RemoveFlag.All
            since: 6
            until: [6, 3]
        }
        ModifyFunction{
            signature: "operator>(QLatin1StringView)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "operator>=(QLatin1String)"
            remove: RemoveFlag.All
            since: 6
            until: [6, 3]
        }
        ModifyFunction{
            signature: "operator>=(QLatin1StringView)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "operator==(QLatin1String)"
            remove: RemoveFlag.All
            since: 6
            until: [6, 3]
        }
        ModifyFunction{
            signature: "operator==(QLatin1StringView)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ExtraIncludes{
            Include{
                fileName: "QtJambi/JavaAPI"
                location: Include.Global
            }
        }
        ModifyFunction{
            signature: "QString(const QChar*,qsizetype)"
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            ModifyArgument{
                index: 2
                RemoveDefaultExpression{
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "QString(const QChar*,int)"
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            ModifyArgument{
                index: 2
                RemoveDefaultExpression{
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "fromLatin1(const char*,int)"
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "fromLocal8Bit(const char*,int)"
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "fromLatin1(const char*,qsizetype)"
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "fromLocal8Bit(const char*,qsizetype)"
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "fromRawData(const QChar*,qsizetype)"
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "fromRawData(const QChar*,int)"
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "fromUcs4(const char32_t*,qsizetype)"
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            since: [6, 2]
        }
        ModifyFunction{
            signature: "fromUcs4(const unsigned int*,qsizetype)"
            remove: RemoveFlag.All
            since: [6, 2]
        }
        ModifyFunction{
            signature: "fromUcs4(const unsigned int*,qsizetype)"
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            since: 6
            until: [6, 2]
        }
        ModifyFunction{
            signature: "fromUcs4(const unsigned int*,int)"
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "fromUtf16(const char16_t*,qsizetype)"
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            since: [6, 2]
        }
        ModifyFunction{
            signature: "fromUtf16(const unsigned short*,qsizetype)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "fromUtf16(const unsigned short*,qsizetype)"
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            since: 6
            until: [6, 3]
        }
        ModifyFunction{
            signature: "fromUtf16(const unsigned short*,int)"
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "fromUtf8(const char*,int)"
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "fromUtf8(const char*,qsizetype)"
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "fill(QChar,qsizetype)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            since: 6
        }
        ModifyFunction{
            signature: "fill(QChar,int)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            until: 5
        }
        ModifyFunction{
            signature: "append(QChar)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "append(QByteArray)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "append(QString)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "prepend(QString)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "insert(qsizetype,QString)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            since: 6
        }
        ModifyFunction{
            signature: "insert(int,QString)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            until: 5
        }
        ModifyFunction{
            signature: "append(const QChar*,qsizetype)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "append(const QChar*,int)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "insert(qsizetype,const QChar*,qsizetype)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            ModifyArgument{
                index: 2
                ArrayType{
                    lengthParameter: 3
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "insert(qsizetype,QChar)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            since: 6
        }
        ModifyFunction{
            signature: "insert(qsizetype,QByteArray)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            since: 6
        }
        ModifyFunction{
            signature: "remove(qsizetype, qsizetype)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            since: 6
        }
        ModifyFunction{
            signature: "insert(int,const QChar*,int)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            ModifyArgument{
                index: 2
                ArrayType{
                    lengthParameter: 3
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "insert(int,QChar)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            until: 5
        }
        ModifyFunction{
            signature: "insert(int,QByteArray)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            until: 5
        }
        ModifyFunction{
            signature: "remove(int, int)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            until: 5
        }
        ModifyFunction{
            signature: "replace(QChar, QChar, Qt::CaseSensitivity)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "replace(QString, QString, Qt::CaseSensitivity)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "replace(qsizetype, qsizetype, QChar)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            since: 6
        }
        ModifyFunction{
            signature: "replace(qsizetype, qsizetype, const QChar*, qsizetype)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            ModifyArgument{
                index: 3
                ArrayType{
                    lengthParameter: 4
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "replace(int, int, QChar)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            until: 5
        }
        ModifyFunction{
            signature: "replace(int, int, const QChar*, int)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            ModifyArgument{
                index: 3
                ArrayType{
                    lengthParameter: 4
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "remove(QChar, Qt::CaseSensitivity)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "remove(QRegularExpression)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "remove(QRegExp)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            until: 5
        }
        ModifyFunction{
            signature: "prepend(QChar)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "prepend(QByteArray)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "remove(QString,Qt::CaseSensitivity)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "replace(QChar,QString,Qt::CaseSensitivity)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "replace(QRegularExpression,QString)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "replace(QRegExp,QString)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            until: 5
        }
        ModifyFunction{
            signature: "swap(QString&)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "io.qt.core.QString"
                }
                NoNullPointer{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QString& %out = *QtJambiAPI::convertJavaObjectToNative<QString>(%env, %in);"}
                }
            }
        }
        ModifyFunction{
            signature: "prepend(const QChar*,qsizetype)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "prepend(const QChar*,int)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "replace(qsizetype, qsizetype, QString)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            since: 6
        }
        ModifyFunction{
            signature: "replace(const QChar*,qsizetype,const QChar*,qsizetype,Qt::CaseSensitivity)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            ModifyArgument{
                index: 3
                ArrayType{
                    lengthParameter: 4
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "prepend(const QChar*,qsizetype)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "replace(int, int, QString)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            until: 5
        }
        ModifyFunction{
            signature: "replace(const QChar*,int,const QChar*,int,Qt::CaseSensitivity)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            ModifyArgument{
                index: 3
                ArrayType{
                    lengthParameter: 4
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "prepend(const QChar*,int)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "lastIndexOf(QRegularExpression,qsizetype,QRegularExpressionMatch*)const"
            ModifyArgument{
                index: 3
                ReplaceType{
                    modifiedType: "io.qt.core.QRegularExpressionMatch"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QRegularExpressionMatch* %out = qtjambi_cast<QRegularExpressionMatch*>(%env, %in);"}
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "indexOf(QRegularExpression,qsizetype,QRegularExpressionMatch*)const"
            ModifyArgument{
                index: 3
                ReplaceType{
                    modifiedType: "io.qt.core.QRegularExpressionMatch"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QRegularExpressionMatch* %out = qtjambi_cast<QRegularExpressionMatch*>(%env, %in);"}
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "lastIndexOf(QRegularExpression,int,QRegularExpressionMatch*)const"
            ModifyArgument{
                index: 3
                ReplaceType{
                    modifiedType: "io.qt.core.QRegularExpressionMatch"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QRegularExpressionMatch* %out = qtjambi_cast<QRegularExpressionMatch*>(%env, %in);"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "indexOf(QRegularExpression,int,QRegularExpressionMatch*)const"
            ModifyArgument{
                index: 3
                ReplaceType{
                    modifiedType: "io.qt.core.QRegularExpressionMatch"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QRegularExpressionMatch* %out = qtjambi_cast<QRegularExpressionMatch*>(%env, %in);"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "lastIndexOf(QRegExp&,int)const"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "io.qt.core.QRegExp"
                }
                NoNullPointer{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QRegExp& %out = qtjambi_cast<QRegExp&>(%env, %in);"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "indexOf(QRegExp&,int)const"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "io.qt.core.QRegExp"
                }
                NoNullPointer{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QRegExp& %out = qtjambi_cast<QRegExp&>(%env, %in);"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "contains(QRegExp&)const"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "io.qt.core.QRegExp"
                }
                NoNullPointer{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QRegExp& %out = qtjambi_cast<QRegExp&>(%env, %in);"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "contains(QRegularExpression,QRegularExpressionMatch*)const"
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "io.qt.core.QRegularExpressionMatch"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QRegularExpressionMatch* %out = qtjambi_cast<QRegularExpressionMatch*>(%env, %in);"}
                }
            }
        }
        ModifyFunction{
            signature: "toInt(bool*,int) const"
            throwing: "NumberFormatException"
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "bool ok(false);\n"+
                                  "bool* %out = &ok;"}
                }
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.End
                Text{content: "if(!ok)\n"+
                              "    Java::Runtime::NumberFormatException::throwNew(%env, \"Unable to parse number.\" QTJAMBI_STACKTRACEINFO );"}
            }
        }
        ModifyFunction{
            signature: "toLongLong(bool*,int) const"
            rename: "toLong"
            throwing: "NumberFormatException"
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "bool ok(false);\n"+
                                  "bool* %out = &ok;"}
                }
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.End
                Text{content: "if(!ok)\n"+
                              "    Java::Runtime::NumberFormatException::throwNew(%env, \"Unable to parse number.\" QTJAMBI_STACKTRACEINFO );"}
            }
        }
        ModifyFunction{
            signature: "toShort(bool*,int) const"
            throwing: "NumberFormatException"
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "bool ok(false);\n"+
                                  "bool* %out = &ok;"}
                }
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.End
                Text{content: "if(!ok)\n"+
                              "    Java::Runtime::NumberFormatException::throwNew(%env, \"Unable to parse number.\" QTJAMBI_STACKTRACEINFO );"}
            }
        }
        ModifyFunction{
            signature: "toDouble(bool*) const"
            throwing: "NumberFormatException"
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "bool ok(false);\n"+
                                  "bool* %out = &ok;"}
                }
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.End
                Text{content: "if(!ok)\n"+
                              "    Java::Runtime::NumberFormatException::throwNew(%env, \"Unable to parse number.\" QTJAMBI_STACKTRACEINFO );"}
            }
        }
        ModifyFunction{
            signature: "toFloat(bool*) const"
            throwing: "NumberFormatException"
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "bool ok(false);\n"+
                                  "bool* %out = &ok;"}
                }
            }
            InjectCode{
                target: CodeClass.Native
                position: Position.End
                Text{content: "if(!ok)\n"+
                              "    Java::Runtime::NumberFormatException::throwNew(%env, \"Unable to parse number.\" QTJAMBI_STACKTRACEINFO );"}
            }
        }
        ModifyFunction{
            signature: "setNum(double, char, int)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "setNum(float, char, int)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "setNum(int, int)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "setNum(long long, int)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "setNum(short, int)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
        }
        ModifyFunction{
            signature: "setRawData(const QChar *, qsizetype)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "setUnicode(const QChar *, qsizetype)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "setUtf16(const unsigned short *, qsizetype)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "setRawData(const QChar *, int)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "setUnicode(const QChar *, int)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "setUtf16(const unsigned short *, int)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            ModifyArgument{
                index: 1
                ArrayType{
                    lengthParameter: 2
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "isSharedWith(QString) const"
            ModifyArgument{
                index: 1
                NoNullPointer{
                }
                ReplaceType{
                    modifiedType: "io.qt.core.QString"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "const QString& %out = *qtjambi_cast<QString*>(%env, %scope, %in);"}
                }
            }
        }
        ModifyFunction{
            signature: "unicode() const"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "char[]"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jint size = jint(__qt_this->size());\n"+
                                  "%out = qtjambi_array_cast<jcharArray>(%env, %scope, %in, size);"}
                }
            }
        }
        ModifyFunction{
            signature: "utf16() const"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "short[]"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jint size = 0;\n"+
                                  "while(%in[size]!=0)\n"+
                                  "    ++size;\n"+
                                  "%out = qtjambi_array_cast<jshortArray>(%env, %scope, %in, size);"}
                }
            }
        }
        ModifyFunction{
            signature: "length()const"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "int"
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "erase(const QChar*)"
            remove: RemoveFlag.All
            since: [6,5]
        }
        ModifyFunction{
            signature: "append(QUtf8StringView)"
            remove: RemoveFlag.All
            since: [6,5]
        }
        ModifyFunction{
            signature: "prepend(QUtf8StringView)"
            remove: RemoveFlag.All
            since: [6,5]
        }
        ModifyFunction{
            signature: "insert(qsizetype,QUtf8StringView)"
            remove: RemoveFlag.All
            since: [6,5]
        }
        ModifyFunction{
            signature: "removeAt(qsizetype)"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            since: [6,5]
        }
        ModifyFunction{
            signature: "removeFirst()"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            since: [6,5]
        }
        ModifyFunction{
            signature: "removeLast()"
            ModifyArgument{
                index: 0
                replaceValue: "this"
            }
            since: [6,5]
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QString__"
                quoteBeforeLine: "}// class"
            }
        }
    }
    
    
    ObjectType{
        name: "QtJambiStringList"
        extendType: "QStringList"
    }
    
    ObjectType{
        name: "QtJambiItemSelection"
        extendType: "QItemSelection"
        since: 6
    }
    
    EnumType{
        name: "QLibrary::LoadHint"
        flags: "QLibrary::LoadHints"
    }
    
    ObjectType{
        name: "QPluginLoader"
        ExtraIncludes{
            Include{
                fileName: "QtJambi/JavaAPI"
                location: Include.Global
            }
            Include{
                fileName: "QtJambi/CoreAPI"
                location: Include.Global
            }
            Include{
                fileName: "java.io.*"
                location: Include.Java
            }
            Include{
                fileName: "java.net.*"
                location: Include.Java
            }
            Include{
                fileName: "java.util.*"
                location: Include.Java
            }
            Include{
                fileName: "java.util.function.*"
                location: Include.Java
            }
            Include{
                fileName: "java.util.logging.*"
                location: Include.Java
            }
            Include{
                fileName: "io.qt.*"
                location: Include.Java
            }
            Include{
                fileName: "io.qt.core.internal.*"
                location: Include.Java
            }
        }
        ModifyFunction{
            signature: "metaData() const"
            ModifyArgument{
                index: 0
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QJsonValue iid = %in.value(\"IID\");\n"+
                                  "if(iid.isString()){\n"+
                                  "    if(jclass iface = CoreAPI::getInterfaceByIID(%env, iid.toString().toUtf8())){\n"+
                                  "        %in.insert(\"interface\", QtJambiAPI::getClassName(%env, iface));\n"+
                                  "    }\n"+
                                  "}\n"+
                                  "%out = qtjambi_cast<jobject>(%env, %in);"}
                }
            }
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QPluginLoader_java__"
                quoteBeforeLine: "}// class"
            }
        }
        since: [5, 13]
    }

    GlobalFunction{
        signature: "qRegisterStaticPluginFunction(QStaticPlugin)"
        remove: RemoveFlag.All
    }

    ObjectType{
        name: "QFactoryLoader"
        packageName: "io.qt.core.internal"
        ExtraIncludes{
            Include{
                fileName: "io.qt.core.*"
                location: Include.Java
            }
            Include{
                fileName: "io.qt.*"
                location: Include.Java
            }
            Include{
                fileName: "java.lang.reflect.*"
                location: Include.Java
            }
            Include{
                fileName: "java.util.logging.*"
                location: Include.Java
            }
            Include{
                fileName: "QtJambi/JavaAPI"
                location: Include.Global
            }
            Include{
                fileName: "QtJambi/CoreAPI"
                location: Include.Global
            }
        }
        ModifyFunction{
            signature: "QFactoryLoader(const char *, const QString &, Qt::CaseSensitivity)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.Class<? extends io.qt.QtObjectInterface>"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "const char* %out = CoreAPI::getInterfaceIID(%env, jclass(%in));\n"+
                                  "if(!%out){\n"+
                                  "    Java::Runtime::IllegalArgumentException::throwNew(%env, QStringLiteral(\"Class %\"\"1 is not registered as plugin interface.\").arg(QtJambiAPI::getClassName(%env, jclass(%in))) QTJAMBI_STACKTRACEINFO);\n"+
                                  "}"}
                }
            }
            InjectCode{
                target: CodeClass.Java
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                Text{content: "io.qt.QtUtilities.initializePackage(%1);"}
            }
            InjectCode{
                target: CodeClass.Java
                since: [6, 3]
                ArgumentMap{
                    index: 2
                    metaName: "%2"
                }
                Text{content: "if(%2==null || !%2.startsWith(\"/\"))\n"+
                              "    throw new IllegalArgumentException(\"For historical reasons, the suffix must start with '/' (and it can't be empty)\");"}
            }
        }
        ModifyFunction{
            signature: "metaData() const"
            ModifyArgument{
                index: 0
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "for(QJsonObject& obj : %in){\n"+
                                  "    if(obj[QStringLiteral(\"IID\")].isString()){\n"+
                                  "        if(jclass iface = CoreAPI::getInterfaceByIID(%env, obj[QStringLiteral(\"IID\")].toString().toUtf8())){\n"+
                                  "            obj[\"interface\"] = QtJambiAPI::getClassName(%env, iface);\n"+
                                  "        }\n"+
                                  "    }\n"+
                                  "}\n"+
                                  "%out = qtjambi_cast<jobject>(%env, %in);"}
                    until: [6, 2]
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "for(QPluginParsedMetaData& obj : __qt_return_value){\n"+
                                  "    QCborMap map = obj.toCbor();\n"+
                                  "    QCborValue iid = map.value(QStringLiteral(\"IID\"));\n"+
                                  "    if(iid.isString()){\n"+
                                  "        if(jclass iface = CoreAPI::getInterfaceByIID(__jni_env, iid.toString().toUtf8())){\n"+
                                  "            map.insert(QStringLiteral(\"interface\"), QtJambiAPI::getClassName(__jni_env, iface));\n"+
                                  "        }\n"+
                                  "    }\n"+
                                  "    obj.~QPluginParsedMetaData();\n"+
                                  "    new (&obj) QCborValue(map);\n"+
                                  "}\n"+
                                  "%out = qtjambi_cast<jobject>(%env, %in);"}
                    since: [6, 3]
                }
            }
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QFactoryLoader__"
                quoteBeforeLine: "}// class"
            }
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QFactoryLoader_62_"
                quoteBeforeLine: "}// class"
                until: [6, 2]
            }
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QFactoryLoader_63_"
                quoteBeforeLine: "}// class"
                since: [6, 3]
            }
        }
        since: [5, 13]
    }
    
    ValueType{
        name: "QPluginParsedMetaData"
        packageName: "io.qt.core.internal"
        CustomConstructor{
            type: CustomConstructor.Copy
            Text{content: "new(placement) QCborValue(copy->toCbor());"}
        }
        ModifyFunction{
            signature: "QPluginParsedMetaData(QByteArrayView)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "toJson() const"
            remove: RemoveFlag.All
        }
        since: [6, 3]
    }
    
    ValueType{
        name: "QStaticPlugin"
        targetType: "final class"
        ExtraIncludes{
            Include{
                fileName: "QtJambi/JObjectWrapper"
                location: Include.Global
            }
            Include{
                fileName: "QtJambi/CoreAPI"
                location: Include.Global
            }
            Include{
                fileName: "QtJambi/JavaAPI"
                location: Include.Global
            }
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QStaticPlugin_java__"
                quoteBeforeLine: "}// class"
            }
        }
        ModifyFunction{
            signature: "metaData() const"
            ModifyArgument{
                index: 0
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QJsonValue iid = %in.value(\"IID\");\n"+
                                  "if(iid.isString()){\n"+
                                  "    if(jclass iface = CoreAPI::getInterfaceByIID(%env, iid.toString().toUtf8())){\n"+
                                  "        %in.take(\"IID\");\n"+
                                  "        %in.insert(\"interface\", QJsonValue::fromVariant(QVariant::fromValue<JObjectWrapper>(JObjectWrapper(%env, iface))));\n"+
                                  "    }\n"+
                                  "}\n"+
                                  "%out = qtjambi_cast<jobject>(%env, %in);"}
                }
            }
        }
        since: [5, 13]
    }
    
    Rejection{
        className: "QMetaType"
        functionName: "destroy"
    }
    
    Rejection{
        className: "QMetaType"
        functionName: "construct"
    }
    
    Rejection{
        className: "QMetaType"
        functionName: "destruct"
    }
    
    Rejection{
        className: "QMetaType"
        functionName: "registerDebugStreamOperator"
    }
    
    Rejection{
        className: "QMetaType"
        functionName: "registerConverter"
    }
    
    Rejection{
        className: "QMetaType"
        functionName: "registerComparators"
    }
    
    Rejection{
        className: "QMetaType"
        functionName: "registerEqualsComparator"
    }
    
    Rejection{
        className: "QMetaType"
        functionName: "registerNormalizedTypedef"
    }
    
    Rejection{
        className: "QMetaType"
        functionName: "registerTypedef"
    }
    
    Rejection{
        className: "QMetaType"
        functionName: "registerConverterFunction"
        since: 6
    }
    
    Rejection{
        className: "QMetaType::ConverterFunction"
    }
    
    Rejection{
        className: "QtPrivate::QMetaTypeInterface"
    }
    
    ValueType{
        name: "QMetaType"
        CustomConstructor{
            Text{content: "if(copy){\n"+
                          "    return new(placement) QMetaType(copy->id());\n"+
                          "}else{\n"+
                          "    return new(placement) QMetaType();\n"+
                          "}"}
        }
        ExtraIncludes{
            Include{
                fileName: "QtJambi/CoreAPI"
                location: Include.Global
            }
            Include{
                fileName: "QtJambi/JavaAPI"
                location: Include.Global
            }
        }
        ModifyFunction{
            signature: "hasRegisteredConverterFunction<From,To>()"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "hasRegisteredComparators<T>()"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "hasRegisteredMutableViewFunction<From,To>()"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "canView(QMetaType,QMetaType)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "hasRegisteredMutableViewFunction(QMetaType,QMetaType)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "operator=(const QMetaType &)"
            remove: RemoveFlag.All
            until: 5
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QMetaType___"
                quoteBeforeLine: "}// class"
            }
        }
        InjectCode{
            until: 5
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QMetaType_5__"
                quoteBeforeLine: "}// class"
            }
        }
        InjectCode{
            since: 6
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QMetaType_6__"
                quoteBeforeLine: "}// class"
            }
        }
        ModifyFunction{
            signature: "fromType<T>()"
            Instantiation{
                proxyCall: "CoreAPI::registerMetaType"
                Argument{
                    type: "QObject"
                }
                AddArgument{
                    index: 1
                    name: "clazz"
                    type: "java.lang.Class<?>"
                }
                AddArgument{
                    index: 2
                    name: "instantiations"
                    type: "io.qt.core.QMetaType..."
                }
                ModifyArgument{
                    index: 0
                    ConversionRule{
                        codeClass: CodeClass.Native
                        Text{content: "%out = qtjambi_cast<jobject>(%env, QMetaType(%in));"}
                    }
                }
            }
            since: [5, 15]
        }
        ModifyFunction{
            signature: "hasRegisteredDebugStreamOperator<T>()"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "compare(const void *, const void *) const"
            InjectCode{
                target: CodeClass.Java
                position: Position.Beginning
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                ArgumentMap{
                    index: 2
                    metaName: "%2"
                }
                Text{content: "%1 = cast(javaType(), %1);\n"+
                              "%2 = cast(javaType(), %2);"}
            }
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "int"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "if(%in==QPartialOrdering::Less){\n"+
                                  "    %out = -1;\n"+
                                  "}else if(%in==QPartialOrdering::Greater){\n"+
                                  "    %out = 1;\n"+
                                  "}else if(%in==QPartialOrdering::Unordered){\n"+
                                  "    %out = -127;\n"+
                                  "}else{\n"+
                                  "    %out = 0;\n"+
                                  "}"}
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.Object"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QVariant var1 = CoreAPI::convertCheckedObjectToQVariant(%env, %in, *__qt_this);\n"+
                                  "const void* %out = var1.data();"}
                }
            }
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.lang.Object"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QVariant var2 = CoreAPI::convertCheckedObjectToQVariant(%env, %in, *__qt_this);\n"+
                                  "const void* %out = var2.data();"}
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "compare(const void *, const void *, int, int *)"
            InjectCode{
                target: CodeClass.Java
                position: Position.Beginning
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                ArgumentMap{
                    index: 2
                    metaName: "%2"
                }
                ArgumentMap{
                    index: 3
                    metaName: "%3"
                }
                Text{content: "%1 = cast(javaType(%3), %1);\n"+
                              "%2 = cast(javaType(%3), %2);"}
            }
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.util.OptionalInt"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "if(%in){\n"+
                                  "    %out = Java::Runtime::OptionalInt::of(%env, %4);\n"+
                                  "}else{\n"+
                                  "    %out = Java::Runtime::OptionalInt::empty(%env);\n"+
                                  "}"}
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.Object"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QVariant var1 = CoreAPI::convertCheckedObjectToQVariant(%env, %in, QMetaType(%3));\n"+
                                  "const void* %out = var1.data();"}
                }
            }
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.lang.Object"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QVariant var2 = CoreAPI::convertCheckedObjectToQVariant(%env, %in, QMetaType(%3));\n"+
                                  "const void* %out = var2.data();"}
                }
            }
            ModifyArgument{
                index: 4
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "int %in = 0;\n"+
                                  "int* %out = &%in;"}
                }
            }
        }
        ModifyFunction{
            signature: "equals(const void *, const void *) const"
            InjectCode{
                target: CodeClass.Java
                position: Position.Beginning
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                ArgumentMap{
                    index: 2
                    metaName: "%2"
                }
                Text{content: "%1 = cast(javaType(), %1);\n"+
                              "%2 = cast(javaType(), %2);"}
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.Object"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QVariant var1 = CoreAPI::convertCheckedObjectToQVariant(%env, %in, *__qt_this);\n"+
                                  "const void* %out = var1.data();"}
                }
            }
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.lang.Object"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QVariant var2 = CoreAPI::convertCheckedObjectToQVariant(%env, %in, *__qt_this);\n"+
                                  "const void* %out = var2.data();"}
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "equals(const void *, const void *, int, int *)"
            InjectCode{
                target: CodeClass.Java
                position: Position.Beginning
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                ArgumentMap{
                    index: 2
                    metaName: "%2"
                }
                ArgumentMap{
                    index: 3
                    metaName: "%3"
                }
                Text{content: "%1 = cast(javaType(%3), %1);\n"+
                              "%2 = cast(javaType(%3), %2);"}
            }
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.util.OptionalInt"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "if(%in){\n"+
                                  "    %out = Java::Runtime::OptionalInt::of(%env, %4);\n"+
                                  "}else{\n"+
                                  "    %out = Java::Runtime::OptionalInt::empty(%env);\n"+
                                  "}"}
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.Object"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QVariant var1 = CoreAPI::convertCheckedObjectToQVariant(%env, %in, QMetaType(%3));\n"+
                                  "const void* %out = var1.data();"}
                }
            }
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.lang.Object"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QVariant var2 = CoreAPI::convertCheckedObjectToQVariant(%env, %in, QMetaType(%3));\n"+
                                  "const void* %out = var2.data();"}
                }
            }
            ModifyArgument{
                index: 4
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "int %in = 0;\n"+
                                  "int* %out = &%in;"}
                }
            }
        }
        ModifyFunction{
            signature: "create(const void *) const"
            InjectCode{
                target: CodeClass.Java
                position: Position.Beginning
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                Text{content: "%1 = cast(javaType(), %1);"}
            }
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.lang.Object"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "*/\n"+
                                  "%out = QtJambiAPI::convertQVariantToJavaObject(%env, variant);"}
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.Object"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QVariant variant = CoreAPI::convertCheckedObjectToQVariant(%env, %in, *__qt_this);\n"+
                                  "/*"}
                }
            }
        }
        ModifyFunction{
            signature: "create(int,const void *)"
            InjectCode{
                target: CodeClass.Java
                position: Position.Beginning
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                ArgumentMap{
                    index: 2
                    metaName: "%2"
                }
                Text{content: "%2 = cast(javaType(%1), %2);"}
            }
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.lang.Object"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "*/\n"+
                                  "%out = QtJambiAPI::convertQVariantToJavaObject(%env, variant);"}
                }
            }
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.lang.Object"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QVariant variant = CoreAPI::convertCheckedObjectToQVariant(%env, %in, QMetaType(%1));\n"+
                                  "/*"}
                }
            }
        }
        ModifyFunction{
            signature: "load(QDataStream &, void *) const"
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)\n"+
                                  "QVariant outVariant(__qt_this->id(), nullptr);\n"+
                                  "#else\n"+
                                  "QVariant outVariant(*__qt_this, nullptr);\n"+
                                  "#endif\n"+
                                  "void *%out = outVariant.data();"}
                }
            }
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.util.Optional<Object>"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "if(%in){\n"+
                                  "    %out = Java::Runtime::Optional::ofNullable(%env, QtJambiAPI::convertQVariantToJavaObject(%env, outVariant));\n"+
                                  "}else{\n"+
                                  "    %out = Java::Runtime::Optional::empty(%env);\n"+
                                  "}"}
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "load(QDataStream &, int, void *)"
            ModifyArgument{
                index: 3
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)\n"+
                                  "QVariant outVariant(%2, nullptr);\n"+
                                  "#else\n"+
                                  "QVariant outVariant(QMetaType(%2), nullptr);\n"+
                                  "#endif\n"+
                                  "void *%out = outVariant.data();"}
                }
            }
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.util.Optional<Object>"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "if(%in){\n"+
                                  "    %out = Java::Runtime::Optional::ofNullable(%env, QtJambiAPI::convertQVariantToJavaObject(%env, outVariant));\n"+
                                  "}else{\n"+
                                  "    %out = Java::Runtime::Optional::empty(%env);\n"+
                                  "}"}
                }
            }
        }
        ModifyFunction{
            signature: "save(QDataStream &, const void *) const"
            InjectCode{
                target: CodeClass.Java
                position: Position.Beginning
                ArgumentMap{
                    index: 2
                    metaName: "%2"
                }
                Text{content: "%2 = cast(javaType(), %2);"}
            }
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.lang.Object"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QVariant variant = CoreAPI::convertCheckedObjectToQVariant(%env, %in, *__qt_this);\n"+
                                  "const void* %out = variant.data();"}
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "save(QDataStream &, int, const void *)"
            InjectCode{
                target: CodeClass.Java
                position: Position.Beginning
                ArgumentMap{
                    index: 2
                    metaName: "%2"
                }
                ArgumentMap{
                    index: 3
                    metaName: "%3"
                }
                Text{content: "%3 = cast(javaType(%2), %3);"}
            }
            ModifyArgument{
                index: 3
                ReplaceType{
                    modifiedType: "java.lang.Object"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QVariant variant = CoreAPI::convertCheckedObjectToQVariant(%env, %in, QMetaType(%2));\n"+
                                  "const void* %out = variant.data();"}
                }
            }
        }
        ModifyFunction{
            signature: "debugStream(QDebug &, const void *)"
            InjectCode{
                target: CodeClass.Java
                position: Position.Beginning
                ArgumentMap{
                    index: 2
                    metaName: "%2"
                }
                Text{content: "%2 = cast(javaType(), %2);"}
            }
            ModifyArgument{
                index: 1
                NoNullPointer{
                }
                ReplaceType{
                    modifiedType: "io.qt.core.QDebug"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QDebug& %out = qtjambi_cast<QDebug&>(%env, %in);"}
                }
            }
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.lang.Object"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QVariant variant = CoreAPI::convertCheckedObjectToQVariant(%env, %in, *__qt_this);\n"+
                                  "const void* %out = variant.data();"}
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "debugStream(QDebug &, const void *, int)"
            InjectCode{
                target: CodeClass.Java
                position: Position.Beginning
                ArgumentMap{
                    index: 2
                    metaName: "%2"
                }
                ArgumentMap{
                    index: 3
                    metaName: "%3"
                }
                Text{content: "%2 = cast(javaType(%3), %2);"}
            }
            ModifyArgument{
                index: 1
                NoNullPointer{
                }
                ReplaceType{
                    modifiedType: "io.qt.core.QDebug"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QDebug& %out = qtjambi_cast<QDebug&>(%env, %in);"}
                }
            }
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.lang.Object"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QVariant variant = CoreAPI::convertCheckedObjectToQVariant(%env, %in, QMetaType(%3));\n"+
                                  "const void* %out = variant.data();"}
                }
            }
        }
        ModifyFunction{
            signature: "convert(QMetaType, const void *, QMetaType, void *)"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.util.Optional<Object>"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "if(%in){\n"+
                                  "    %out = Java::Runtime::Optional::ofNullable(%env, QtJambiAPI::convertQVariantToJavaObject(%env, variant4));\n"+
                                  "}else{\n"+
                                  "    %out = Java::Runtime::Optional::empty(%env);\n"+
                                  "}"}
                }
            }
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.lang.Object"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QVariant variant2 = CoreAPI::convertCheckedObjectToQVariant(%env, %in, __qt_%1);\n"+
                                  "const void * %out = variant2.data();"}
                }
            }
            ModifyArgument{
                index: 4
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)\n"+
                                  "QVariant variant4(__qt_%3.id(), nullptr);\n"+
                                  "#else\n"+
                                  "QVariant variant4(__qt_%3, nullptr);\n"+
                                  "#endif\n"+
                                  "void * %out = variant4.data();"}
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "convert(const void *, int, void *, int)"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.util.Optional<Object>"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "if(%in){\n"+
                                  "    %out = Java::Runtime::Optional::ofNullable(%env, QtJambiAPI::convertQVariantToJavaObject(%env, variant3));\n"+
                                  "}else{\n"+
                                  "    %out = Java::Runtime::Optional::empty(%env);\n"+
                                  "}"}
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.Object"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QVariant variant1 = CoreAPI::convertCheckedObjectToQVariant(%env, %in, QMetaType(%2));\n"+
                                  "const void * %out = variant1.data();"}
                }
            }
            ModifyArgument{
                index: 3
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)\n"+
                                  "QVariant variant3(%4, nullptr);\n"+
                                  "#else\n"+
                                  "QVariant variant3(QMetaType(%4), nullptr);\n"+
                                  "#endif\n"+
                                  "void * %out = variant3.data();"}
                }
            }
        }
        ModifyFunction{
            signature: "type(const char *)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        ModifyFunction{
            signature: "typeName(int)"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        ModifyFunction{
            signature: "name()const"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
            since: 6
        }
    }
    
    EnumType{
        name: "QMetaType::TypeFlag"
        flags: "QMetaType::TypeFlags"
        RejectEnumValue{
            name: "MovableType"
            since: 6
        }
    }
    
    Rejection{
        className: "QVariant"
        functionName: "view"
    }
    
    Rejection{
        className: "QVariant"
        functionName: "view<T>"
    }
    
    Rejection{
        className: "QVariant"
        functionName: "canView"
    }
    
    Rejection{
        className: "QVariant"
        functionName: "canView<T>"
    }
    
    ValueType{
        name: "QVariant"
        ExtraIncludes{
            Include{
                fileName: "QtCore/QScopeGuard"
                location: Include.Global
            }
            Include{
                fileName: "QtJambi/CoreAPI"
                location: Include.Global
            }
            Include{
                fileName: "QtJambi/JavaAPI"
                location: Include.Global
            }
        }
        ModifyFunction{
            signature: "QVariant(QMap<QString,QVariant>)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.util.NavigableMap<String,? extends Object>"
                }
            }
        }
        ModifyFunction{
            signature: "QVariant(unsigned long long)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "QVariant(unsigned int)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "QVariant(QStringList)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "QVariant(const char*)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "QVariant(QLatin1String)"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "QVariant(QLatin1StringView)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "data()"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "constData()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator=(QVariant)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "toReal(bool*)const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "toUInt(bool*)const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "toULongLong(bool*)const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "canConvert<T>()const"
            remove: RemoveFlag.All
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QVariant___"
                quoteBeforeLine: "}// class"
            }
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QVariant_5__"
                quoteBeforeLine: "}// class"
                until: 5
            }
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QVariant_6__"
                quoteBeforeLine: "}// class"
                since: 6
            }
        }
        ModifyFunction{
            signature: "QVariant(int, const void *, unsigned int)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "QVariant(QVariant)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.Object"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QVariant variant = QtJambiAPI::convertJavaObjectToQVariant(%env, %in);\n"+
                                  "auto __scope = qScopeGuard([&](){reinterpret_cast<QVariant*>(__qtjambi_ptr)->swap(variant);});\n"+
                                  "QMetaType %out(QMetaType::UnknownType);"}
                    since: 6
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QVariant variant = QtJambiAPI::convertJavaObjectToQVariant(%env, %in);\n"+
                                  "auto __scope = qScopeGuard([&](){reinterpret_cast<QVariant*>(__qtjambi_ptr)->swap(variant);});\n"+
                                  "int %out = QMetaType::UnknownType;"}
                    until: 5
                }
            }
        }
        ModifyFunction{
            signature: "QVariant(int,const void*)"
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.lang.Object"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QVariant variant = CoreAPI::convertCheckedObjectToQVariant(%env, %in, QMetaType(%1));\n"+
                                  "auto __scope = qScopeGuard([&](){reinterpret_cast<QVariant*>(__qtjambi_ptr)->swap(variant);});\n"+
                                  "%1 = QMetaType::UnknownType;\n"+
                                  "const void * %out = nullptr;"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "QVariant(QMetaType,const void*)"
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.lang.Object"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QVariant variant = CoreAPI::convertCheckedObjectToQVariant(%env, %in, __qt_%1);\n"+
                                  "auto __scope = qScopeGuard([&](){reinterpret_cast<QVariant*>(__qtjambi_ptr)->swap(variant);});\n"+
                                  "__qt_%1 = QMetaType(QMetaType::UnknownType);\n"+
                                  "const void * %out = nullptr;"}
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "toBool()const"
            rename: "toBoolean"
        }
        ModifyFunction{
            signature: "toInt(bool*)const"
            ModifyArgument{
                index: 1
                ArrayType{
                    minLength: 1
                }
            }
        }
        ModifyFunction{
            signature: "toDouble(bool*)const"
            ModifyArgument{
                index: 1
                ArrayType{
                    minLength: 1
                }
            }
        }
        ModifyFunction{
            signature: "toLongLong(bool*)const"
            rename: "toLong"
            ModifyArgument{
                index: 1
                ArrayType{
                    minLength: 1
                }
            }
        }
        ModifyFunction{
            signature: "toFloat(bool*)const"
            ModifyArgument{
                index: 1
                ArrayType{
                    minLength: 1
                }
            }
        }
        ModifyFunction{
            signature: "operator=(QVariant)"
            rename: "setValue"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.Object"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QVariant %out = QtJambiAPI::convertJavaObjectToQVariant(%env, %in);"}
                }
            }
            until: 5
        }
        ModifyFunction{
            signature: "setValue(QVariant)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.Object"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QVariant %out = QtJambiAPI::convertJavaObjectToQVariant(%env, %in);"}
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "compare(QVariant,QVariant)"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "int"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "if(%in==QPartialOrdering::Less){\n"+
                                  "    %out = -1;\n"+
                                  "}else if(%in==QPartialOrdering::Greater){\n"+
                                  "    %out = 1;\n"+
                                  "}else if(%in==QPartialOrdering::Unordered){\n"+
                                  "    %out = -127;\n"+
                                  "}else{\n"+
                                  "    %out = 0;\n"+
                                  "}"}
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "data()const"
            rename: "value"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "Object"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "Q_UNUSED(%in)\n"+
                                  "%out = QtJambiAPI::convertQVariantToJavaObject(%env, *__qt_this);"}
                }
            }
        }
        ModifyFunction{
            signature: "convert(int, void *)const"
            rename: "convertTo"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.util.Optional<Object>"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "jobject %out = nullptr;\n"+
                                  "if(%in){\n"+
                                  "    %out = Java::Runtime::Optional::ofNullable(%env, QtJambiAPI::convertQVariantToJavaObject(%env, variant2));\n"+
                                  "}else{\n"+
                                  "    %out = Java::Runtime::Optional::empty(%env);\n"+
                                  "}"}
                }
            }
            ModifyArgument{
                index: 2
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)\n"+
                                  "QVariant variant2(%1, nullptr);\n"+
                                  "#else\n"+
                                  "QVariant variant2(QMetaType(%1), nullptr);\n"+
                                  "#endif\n"+
                                  "void * %out = variant2.data();"}
                }
            }
        }
        ModifyFunction{
            signature: "create(int,const void *)"
            InjectCode{
                target: CodeClass.Java
                position: Position.Beginning
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                ArgumentMap{
                    index: 2
                    metaName: "%2"
                }
                Text{content: "%2 = QMetaType.cast(QMetaType.javaType(%1), %2);"}
            }
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.lang.Object"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QVariant variant = CoreAPI::convertCheckedObjectToQVariant(%env, %in, QMetaType(%1));\n"+
                                  "const void* %out = variant.data();"}
                }
            }
        }
        ModifyFunction{
            signature: "create(QMetaType,const void *)"
            InjectCode{
                target: CodeClass.Java
                position: Position.Beginning
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                ArgumentMap{
                    index: 2
                    metaName: "%2"
                }
                Text{content: "%2 = QMetaType.cast(%1.javaType(), %2);"}
            }
            ModifyArgument{
                index: 2
                ReplaceType{
                    modifiedType: "java.lang.Object"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QVariant variant = CoreAPI::convertCheckedObjectToQVariant(%env, %in, __qt_%1);\n"+
                                  "const void* %out = variant.data();"}
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "nameToType(const char*)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        ModifyFunction{
            signature: "typeName()const"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        ModifyFunction{
            signature: "typeToName(int)"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        ModifyFunction{
            signature: "fromValue<T>(T)"
            Instantiation{
                proxyCall: "QtJambiAPI::convertQVariantToJavaVariant"
                Argument{
                    type: "QVariant"
                }
                Argument{
                    type: "QVariant"
                }
                AddTypeParameter{
                    name: "T"
                }
                ModifyArgument{
                    index: 0
                    ReplaceType{
                        modifiedType: "io.qt.core.QVariant"
                    }
                    ConversionRule{
                        codeClass: CodeClass.Native
                        Text{content: "%out = %in;"}
                    }
                }
                ModifyArgument{
                    index: 1
                    ReplaceType{
                        modifiedType: "T"
                    }
                }
            }
        }
        ModifyFunction{
            signature: "value<T>()const"
            Instantiation{
                Argument{
                    type: "QVariant"
                }
                AddArgument{
                    name: "clazz"
                    type: "java.lang.Class<T>"
                }
                AddArgument{
                    name: "instantiations"
                    type: "io.qt.core.QMetaType..."
                }
                AddTypeParameter{
                    name: "T"
                }
                ModifyArgument{
                    index: 0
                    ReplaceType{
                        modifiedType: "T"
                    }
                    ConversionRule{
                        codeClass: CodeClass.Native
                        Text{content: "int typeId = CoreAPI::metaTypeId(%env, clazz, instantiations);\n"+
                                      "if(typeId==QMetaType::UnknownType || (%in.userType()!=typeId && !%in.convert(typeId)))\n"+
                                      "    %in = QVariant(typeId, nullptr);\n"+
                                      "%out = qtjambi_cast<jobject>(%env, %in);"}
                        until: [5, 15]
                    }
                    ConversionRule{
                        codeClass: CodeClass.Native
                        Text{content: "QMetaType typeId(CoreAPI::metaTypeId(%env, clazz, instantiations));\n"+
                                      "if(!typeId.isValid() || (%in.metaType()!=typeId && !%in.convert(typeId)))\n"+
                                      "    %in = QVariant(typeId, nullptr);\n"+
                                      "%out = qtjambi_cast<jobject>(%env, %in);"}
                        since: 6
                    }
                }
            }
        }
    }
    
    EnumType{
        name: "QVariant::Type"
        extensible: true
    }
    
    ObjectType{
        name: "QPartialOrdering"
        targetType: "final class"
        generate: "no-shell"
        ModifyFunction{
            signature: "QPartialOrdering()"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "qHash(QPartialOrdering)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator==(QPartialOrdering)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator!=(QPartialOrdering)"
            remove: RemoveFlag.All
        }
        ModifyField{
            name: "Equivalent"
            read: false
            write: false
        }
        ModifyField{
            name: "Greater"
            read: false
            write: false
        }
        ModifyField{
            name: "Less"
            read: false
            write: false
        }
        ModifyField{
            name: "Unordered"
            read: false
            write: false
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QPartialOrdering___"
                quoteBeforeLine: "}// class"
            }
        }
        since: 6
    }
    
    EnumType{
        name: "QResource::Compression"
    }
    
    ObjectType{
        name: "QResource"
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QResource__"
                quoteBeforeLine: "}// class"
            }
        }
        ExtraIncludes{
            Include{
                fileName: "QtJambi/JavaAPI"
                location: Include.Global
            }
        }
        InjectCode{
            target: CodeClass.Java
            position: Position.Beginning
            Text{content: "private static final java.util.List<java.nio.ByteBuffer> registeredBuffers = new java.util.ArrayList<>();"}
        }
        ModifyFunction{
            signature: "data()const"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.nio.ByteBuffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = %env->NewDirectByteBuffer(const_cast<char*>(reinterpret_cast<const char*>(%in)), jlong(__qt_this->size()));\n"+
                                  "%out = Java::Runtime::ByteBuffer::asReadOnlyBuffer(%env, %out);"}
                }
            }
        }
        ModifyFunction{
            signature: "registerResource(const unsigned char *, const QString &)"
            InjectCode{
                target: CodeClass.Java
                position: Position.Beginning
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                Text{content: "if(!%1.isDirect()){\n"+
                              "    throw new IllegalArgumentException(\"Only direct buffers allowed.\");\n"+
                              "}"}
            }
            InjectCode{
                target: CodeClass.Java
                position: Position.End
                ArgumentMap{
                    index: 0
                    metaName: "%0"
                }
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                Text{content: "if(%0){\n"+
                              "    registeredBuffers.add(%1);\n"+
                              "}"}
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.nio.ByteBuffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "const unsigned char * %out = reinterpret_cast<const unsigned char *>(%env->GetDirectBufferAddress(%in));"}
                }
            }
        }
        ModifyFunction{
            signature: "unregisterResource(const unsigned char *, const QString &)"
            InjectCode{
                target: CodeClass.Java
                position: Position.Beginning
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                Text{content: "if(!%1.isDirect()){\n"+
                              "    throw new IllegalArgumentException(\"Only direct buffers allowed.\");\n"+
                              "}"}
            }
            InjectCode{
                target: CodeClass.Java
                position: Position.End
                ArgumentMap{
                    index: 0
                    metaName: "%0"
                }
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                Text{content: "if(%0){\n"+
                              "    registeredBuffers.remove(%1);\n"+
                              "}"}
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.nio.ByteBuffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "const unsigned char * %out = reinterpret_cast<const unsigned char *>(%env->GetDirectBufferAddress(%in));"}
                }
            }
        }
    }
    
    EnumType{
        name: "QSharedMemory::AccessMode"
    }
    
    EnumType{
        name: "QSharedMemory::SharedMemoryError"
    }
    
    ObjectType{
        name: "QSharedMemory"
        ModifyFunction{
            signature: "data()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "constData()const"
            remove: RemoveFlag.All
        }
        ExtraIncludes{
            Include{
                fileName: "utils_p.h"
                location: Include.Local
            }
        }
        ModifyFunction{
            signature: "lock()"
            access: Modification.Private
            threadAffinity: false
        }
        ModifyFunction{
            signature: "unlock()"
            access: Modification.Private
            threadAffinity: false
        }
        ModifyFunction{
            signature: "data()"
            access: Modification.Private
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.nio.ByteBuffer"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = %env->NewDirectByteBuffer(%in, jlong(__qt_this->size()));\n"+
                                  "JavaException::check(%env QTJAMBI_STACKTRACEINFO );"}
                }
            }
        }
        ModifyFunction{
            signature: "create(int, QSharedMemory::AccessMode)"
            InjectCode{
                target: CodeClass.Java
                position: Position.End
                Text{content: "if(__qt_return_value){\n"+
                              "    __qt_accessMode = mode;\n"+
                              "}"}
            }
            until: 5
        }
        ModifyFunction{
            signature: "create(qsizetype, QSharedMemory::AccessMode)"
            InjectCode{
                target: CodeClass.Java
                position: Position.End
                Text{content: "if(__qt_return_value){\n"+
                              "    __qt_accessMode = mode;\n"+
                              "}"}
            }
            since: 6
        }
        ModifyFunction{
            signature: "attach(QSharedMemory::AccessMode)"
            InjectCode{
                target: CodeClass.Java
                position: Position.End
                Text{content: "if(__qt_return_value){\n"+
                              "    __qt_accessMode = mode;\n"+
                              "}"}
            }
        }
        InjectCode{
            target: CodeClass.Java
            position: Position.Beginning
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QSharedMemory_java__"
                quoteBeforeLine: "}// class"
            }
        }
    }
    
    EnumType{
        name: "QMetaType::Type"
        extensible: true
        RejectEnumValue{
            name: "QReal"
            remove: true
        }
        RejectEnumValue{
            name: "FirstCoreType"
        }
        RejectEnumValue{
            name: "LastCoreType"
        }
        RejectEnumValue{
            name: "FirstGuiType"
        }
        RejectEnumValue{
            name: "LastGuiType"
        }
        RejectEnumValue{
            name: "FirstWidgetsType"
        }
        RejectEnumValue{
            name: "LastWidgetsType"
        }
        RejectEnumValue{
            name: "HighestInternalId"
        }
    }
    
    ValueType{
        name: "QCalendar"
        ModifyFunction{
            signature: "QCalendar(QLatin1String)"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        InjectCode{
            target: CodeClass.Java
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QCalendar___"
                quoteBeforeLine: "}// class"
            }
        }
        since: [5, 14]
    }
    
    ValueType{
        name: "QCalendar::YearMonthDay"
        since: [5, 14]
    }
    
    EnumType{
        name: "QCalendar::System"
        RejectEnumValue{
            name: "Last"
        }
        since: [5, 14]
    }
    
    EnumType{
        name: "QDateTime::YearRange"
        since: [5, 14]
    }
    
    ObjectType{
        name: "QBasicMutex"
        ModifyFunction{
            signature: "lock()"
            access: Modification.NonFinal
        }
        ModifyFunction{
            signature: "unlock()"
            access: Modification.NonFinal
        }
        ModifyFunction{
            signature: "tryLock()"
            access: Modification.NonFinal
        }
        ModifyFunction{
            signature: "isRecursive()"
            remove: RemoveFlag.All
            until: 5
        }
    }
    
    ObjectType{
        name: "QRecursiveMutex"
    }
    
    ObjectType{
        name: "QMutex"
        ModifyFunction{
            signature: "isRecursive()const"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "try_lock()"
            rename: "tryLock"
        }
    }
    
    ObjectType{
        name: "QSemaphore"
    }
    
    EnumType{
        name: "QSystemSemaphore::AccessMode"
    }
    
    EnumType{
        name: "QSystemSemaphore::SystemSemaphoreError"
    }
    
    ObjectType{
        name: "QSystemSemaphore"
        ModifyFunction{
            signature: "tr(const char *, const char *, int)"
            remove: RemoveFlag.All
            since: [6, 1]
        }
    }
    
    ObjectType{
        name: "QReadWriteLock"
    }
    
    EnumType{
        name: "QReadWriteLock::RecursionMode"
    }
    
    EnumType{
        name: "QMutex::RecursionMode"
    }
    
    ObjectType{
        name: "QWaitCondition"
        ModifyFunction{
            signature: "notify_all()"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "notify_one()"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "wait(QReadWriteLock *, QDeadlineTimer)"
            ModifyArgument{
                index: 2
                ReplaceDefaultExpression{
                    expression: "new QDeadlineTimer(QDeadlineTimer.ForeverConstant.Forever)"
                }
            }
        }
        ModifyFunction{
            signature: "wait(QMutex *, QDeadlineTimer)"
            ModifyArgument{
                index: 2
                ReplaceDefaultExpression{
                    expression: "new QDeadlineTimer(QDeadlineTimer.ForeverConstant.Forever)"
                }
            }
        }
    }
    
    ObjectType{
        name: "QUntypedPropertyData"
        since: 6
    }
    
    ValueType{
        name: "QUntypedBindable"
        ModifyFunction{
            signature: "QUntypedBindable(QUntypedPropertyData *, const QtPrivate::QBindableInterface *)"
            remove: RemoveFlag.JavaOnly
        }
        ModifyFunction{
            signature: "QUntypedBindable(QObject*,const char*,const QtPrivate::QBindableInterface *)"
            remove: RemoveFlag.All
            since: [6, 5]
        }
        ModifyFunction{
            signature: "QUntypedBindable(QObject*,QMetaProperty,const QtPrivate::QBindableInterface *)"
            remove: RemoveFlag.All
            since: [6, 5]
        }
        ModifyFunction{
            signature: "takeBinding()"
            access: Modification.NonFinal
            since: [6, 1]
        }
        ModifyField{
            name: "data"
            ReferenceCount{
                action: ReferenceCount.Ignore
            }
        }
        ModifyField{
            name: "iface"
            ReferenceCount{
                action: ReferenceCount.Ignore
            }
        }
        ModifyFunction{
            signature: "setBinding(QUntypedPropertyBinding)"
            InjectCode{
                target: CodeClass.Java
                position: Position.Beginning
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                Text{content: "if(iface()!=null && %1!=null && !io.qt.core.QProperty.checkType(iface().metaType(), %1.valueMetaType()))\n"+
                              "    return false;"}
            }
        }
        ModifyFunction{
            signature: "makeBinding(QPropertyBindingSourceLocation)"
            access: Modification.NonFinal
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QPropertyBindingSourceLocation %out = QT_PROPERTY_DEFAULT_BINDING_LOCATION;"}
                }
            }
            until: [6, 1]
        }
        ModifyFunction{
            signature: "makeBinding(QPropertyBindingSourceLocation)const"
            access: Modification.NonFinal
            ModifyArgument{
                index: 1
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QPropertyBindingSourceLocation %out = QT_PROPERTY_DEFAULT_BINDING_LOCATION;"}
                }
            }
            since: [6, 2]
        }
        ModifyFunction{
            signature: "binding()const"
            access: Modification.NonFinal
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QUntypedBindable_java__"
                quoteBeforeLine: "}// class"
            }
        }
        since: 6
    }
    
    ObjectType{
        name: "QPropertyObserverBase"
        ModifyFunction{
            signature: "QPropertyObserverBase()"
            remove: RemoveFlag.All
        }
        since: 6
    }
    
    ObjectType{
        name: "QtPrivate::QBindableInterface"
        javaName: "QBindableInterface"
        forceFriendly: true
        ModifyFunction{
            signature: "QBindableInterface()"
            remove: RemoveFlag.All
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QBindableInterface__"
                quoteBeforeLine: "}// class"
            }
        }
        since: 6
    }
    
    Rejection{
        className: "QtPrivate::QBindableInterface"
        fieldName: "getter"
        since: 6
    }
    
    Rejection{
        className: "QtPrivate::QBindableInterface"
        fieldName: "setter"
        since: 6
    }
    
    Rejection{
        className: "QtPrivate::QBindableInterface"
        fieldName: "makeBinding"
        since: 6
    }
    
    Rejection{
        className: "QtPrivate::QBindableInterface"
        fieldName: "setBinding"
        since: 6
    }
    
    Rejection{
        className: "QtPrivate::QBindableInterface"
        fieldName: "getBinding"
        since: 6
    }
    
    Rejection{
        className: "QtPrivate::QBindableInterface"
        fieldName: "setObserver"
        since: 6
    }
    
    Rejection{
        className: "QtPrivate::QBindableInterface"
        fieldName: "metaType"
        since: 6
    }
    
    Rejection{
        className: "QtPrivate::QBindableInterface"
        fieldName: "MetaTypeAccessorFlag"
        since: [6, 2]
    }
    
    ObjectType{
        name: "QPropertyObserver"
        ExtraIncludes{
            Include{
                fileName: "utils_p.h"
                location: Include.Local
            }
        }
        ModifyFunction{
            signature: "setSource(QtPrivate::QPropertyBindingData)"
            access: Modification.Friendly
        }
        InjectCode{
            target: CodeClass.Native
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QPropertyObserver_native__"
                quoteBeforeLine: "}// class"
            }
        }
        InjectCode{
            target: CodeClass.ShellDeclaration
            position: Position.End
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QPropertyObserver_shell__"
                quoteBeforeLine: "}// class"
            }
        }
        since: 6
    }
    
    ValueType{
        name: "QPropertyBindingError"
        ModifyFunction{
            signature: "operator=(const QPropertyBindingError&)"
            remove: RemoveFlag.All
        }
        since: 6
    }
    
    EnumType{
        name: "QPropertyBindingError::Type"
        since: 6
    }
    
    ValueType{
        name: "QUntypedPropertyBinding"
        ModifyFunction{
            signature: "QUntypedPropertyBinding(const QUntypedPropertyBinding&)"
            remove: RemoveFlag.JavaOnly
        }
        ModifyFunction{
            signature: "operator=(const QUntypedPropertyBinding&)"
            remove: RemoveFlag.All
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QUntypedPropertyBinding_java__"
                quoteBeforeLine: "}// class"
            }
        }
        since: 6
    }
    
    Rejection{
        className: "QPropertyObserverBase::ChangeHandler"
    }
    
    ObjectType{
        name: "QtPrivate::QPropertyBindingData"
        javaName: "QPropertyBindingData"
        forceFriendly: true
        ModifyField{
            name: "BindingBit"
            read: false
            write: false
        }
        ModifyField{
            name: "DelayedNotificationBit"
            read: false
            write: false
            since: [6, 2]
        }
        ExtraIncludes{
            Include{
                fileName: "utils_p.h"
                location: Include.Local
            }
        }
        ModifyFunction{
            signature: "setBinding(QUntypedPropertyBinding, QUntypedPropertyData *, QtPrivate::QPropertyObserverCallback, QtPrivate::QPropertyBindingWrapper)"
            ModifyArgument{
                index: 2
                ReferenceCount{
                    action: ReferenceCount.Ignore
                }
            }
            ModifyArgument{
                index: 3
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QtPrivate::QPropertyObserverCallback %out = qtjambi_get_signal_callback(%env, __qt_%2);"}
                }
            }
            ModifyArgument{
                index: 4
                RemoveArgument{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QtPrivate::QPropertyBindingWrapper %out = nullptr;"}
                }
            }
        }
        since: 6
    }
    
    ValueType{
        name: "QPropertyBindingSourceLocation"
        generate: false
        since: 6
    }
    
    ObjectType{
        name: "QBindingStorage"
        forceFriendly: true
        since: 6
    }
    
    FunctionalType{
        name: "QtPrivate::QPropertyObserverCallback"
        generate: false
        javaName: "QPropertyObserverCallback"
        since: 6
    }
    
    FunctionalType{
        name: "QtPrivate::QPropertyBindingWrapper"
        generate: false
        javaName: "QPropertyBindingWrapper"
        since: 6
    }
    
    ObjectType{
        name: "QLoggingCategory"
        ModifyFunction{
            signature: "operator()()"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator()()const"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "QLoggingCategory(const char *, QtMsgType)"
            access: Modification.Private
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QByteArray* _byte_%out = qtjambi_cast<QByteArray*>(%env, %in);\n"+
                                  "const char* %out = _byte_%out ? _byte_%out->data() : nullptr;"}
                }
            }
            InjectCode{
                target: CodeClass.Java
                position: Position.End
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                Text{content: "__rcCategory = %1;"}
            }
        }
        ModifyFunction{
            signature: "QLoggingCategory(const char *)"
            access: Modification.Private
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "io.qt.core.QByteArray"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QByteArray* _byte_%out = qtjambi_cast<QByteArray*>(%env, %in);\n"+
                                  "const char* %out = _byte_%out ? _byte_%out->data() : nullptr;"}
                }
            }
            InjectCode{
                target: CodeClass.Java
                position: Position.End
                ArgumentMap{
                    index: 1
                    metaName: "%1"
                }
                Text{content: "__rcCategory = %1;"}
            }
            until: 5
        }
        ModifyFunction{
            signature: "categoryName() const"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QLoggingCategory__"
                quoteBeforeLine: "}// class"
            }
        }
    }
    
    FunctionalType{
        name: "QLoggingCategory::CategoryFilter"
    }
    
    ObjectType{
        name: "QMessageLogContext"
        ModifyFunction{
            signature: "QMessageLogContext(const char *, int, const char *, const char *)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
            ModifyArgument{
                index: 3
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
            ModifyArgument{
                index: 4
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        ModifyField{
            name: "file"
            write: false
            ReplaceType{
                modifiedType: "java.lang.String"
            }
        }
        ModifyField{
            name: "function"
            write: false
            ReplaceType{
                modifiedType: "java.lang.String"
            }
        }
        ModifyField{
            name: "category"
            write: false
            ReplaceType{
                modifiedType: "java.lang.String"
            }
        }
        ModifyField{
            name: "line"
            write: false
        }
        ModifyField{
            name: "version"
            read: false
            write: false
        }
    }
    
    Rejection{
        className: "QDebug::Stream"
    }
    
    Rejection{
        className: "QDebug"
        enumName: "Latin1Content"
    }
    
    EnumType{
        name: "QDebug::VerbosityLevel"
        forceInteger: true
    }
    
    ObjectType{
        name: "QDebugStateSaver"
        implementing: "java.lang.AutoCloseable"
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class autoclosedelete"
                quoteBeforeLine: "}// class"
            }
        }
        ModifyFunction{
            signature: "QDebugStateSaver(QDebug&)"
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "io.qt.core.QDebug"
                }
                NoNullPointer{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QDebug* _%out = qtjambi_cast<QDebug*>(%env, %in);\n"+
                                  "QDebug& %out = *_%out;"}
                }
            }
        }
    }
    
    ValueType{
        name: "QDebug"
        implementing: "java.lang.AutoCloseable, java.lang.Appendable"
        CustomConstructor{
            Text{content: "if(copy){\n"+
                          "    return new(placement) QDebug(*copy);\n"+
                          "}else{\n"+
                          "    return new(placement) QDebug(QtDebugMsg);\n"+
                          "}"}
        }
        CustomConstructor{
            type: CustomConstructor.Default
            Text{content: "new(placement) QDebug(QtDebugMsg);"}
        }
        ModifyFunction{
            signature: "QDebug(QString *)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator=(QDebug)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator<<(QLatin1StringView)"
            remove: RemoveFlag.All
            since: [6, 4]
        }
        ModifyFunction{
            signature: "operator<<(QLatin1String)"
            remove: RemoveFlag.All
            until: [6, 3]
        }
        ModifyFunction{
            signature: "operator<<(QStringRef)"
            remove: RemoveFlag.All
            until: 5
        }
        ModifyFunction{
            signature: "operator<<(QStringView)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator<<(QUtf8StringView)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "operator<<(const void*)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator<<(uint)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator<<(ulong)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator<<(unsigned short)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator<<(signed long)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator<<(unsigned long long)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator<<(std::nullptr_t)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator<<(char16_t)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator<<(const char16_t*)"
            remove: RemoveFlag.All
            since: 6
        }
        ModifyFunction{
            signature: "operator<<(qfloat16)"
            remove: RemoveFlag.All
            since: [6,5]
        }
        ModifyFunction{
            signature: "operator<<(char32_t)"
            remove: RemoveFlag.All
        }
        InjectCode{
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class autoclosedelete"
                quoteBeforeLine: "}// class"
            }
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QDebug___"
                quoteBeforeLine: "}// class"
            }
        }
        ModifyFunction{
            signature: "QDebug(QIODevice *)"
            ModifyArgument{
                index: 1
                ReferenceCount{
                    variableName: "__rcDevice"
                    action: ReferenceCount.Set
                }
            }
        }
        ModifyFunction{
            signature: "QDebug(QDebug)"
            InjectCode{
                Text{content: "__rcDevice = o.__rcDevice;"}
            }
        }
        ModifyFunction{
            signature: "swap(QDebug&)"
            InjectCode{
                Text{content: "Object __rcDevice = this.__rcDevice;\n"+
                              "this.__rcDevice = other.__rcDevice;\n"+
                              "other.__rcDevice = __rcDevice;"}
            }
        }
        ModifyFunction{
            signature: "maybeQuote(char)"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QDebug"
                }
            }
        }
        ModifyFunction{
            signature: "maybeSpace()"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QDebug"
                }
            }
        }
        ModifyFunction{
            signature: "noquote()"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QDebug"
                }
            }
        }
        ModifyFunction{
            signature: "nospace()"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QDebug"
                }
            }
        }
        ModifyFunction{
            signature: "operator<<(QChar)"
            rename: "append"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QDebug"
                }
            }
        }
        ModifyFunction{
            signature: "operator<<(const char*)"
            rename: "append"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QDebug"
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.String"
                }
            }
        }
        ModifyFunction{
            signature: "operator<<(QString)"
            rename: "append"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QDebug"
                }
            }
            ModifyArgument{
                index: 1
                ReplaceType{
                    modifiedType: "java.lang.CharSequence"
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "QString %out = qtjambi_cast<QString>(%env, %1);"}
                }
            }
        }
        ModifyFunction{
            signature: "operator<<(bool)"
            rename: "append"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QDebug"
                }
            }
        }
        ModifyFunction{
            signature: "operator<<(char)"
            rename: "append"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QDebug"
                }
            }
        }
        ModifyFunction{
            signature: "operator<<(QByteArray)"
            rename: "append"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QDebug"
                }
            }
        }
        ModifyFunction{
            signature: "operator<<(QByteArrayView)"
            rename: "append"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QDebug"
                }
            }
            since: 6
        }
        ModifyFunction{
            signature: "operator<<(double)"
            rename: "append"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QDebug"
                }
            }
        }
        ModifyFunction{
            signature: "operator<<(float)"
            rename: "append"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QDebug"
                }
            }
        }
        ModifyFunction{
            signature: "operator<<(long long)"
            rename: "append"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QDebug"
                }
            }
        }
        ModifyFunction{
            signature: "operator<<(signed short)"
            rename: "append"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QDebug"
                }
            }
        }
        ModifyFunction{
            signature: "operator<<(signed int)"
            rename: "append"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QDebug"
                }
            }
        }
        ModifyFunction{
            signature: "quote()"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QDebug"
                }
            }
        }
        ModifyFunction{
            signature: "resetFormat()"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QDebug"
                }
            }
        }
        ModifyFunction{
            signature: "space()"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QDebug"
                }
            }
        }
        ModifyFunction{
            signature: "verbosity(int)"
            ModifyArgument{
                index: "return"
                replaceValue: "this"
                ReplaceType{
                    modifiedType: "io.qt.core.QDebug"
                }
            }
        }
    }
    
    EnumType{
        name: "QRandomGenerator::System"
        generate: false
    }
    
    ObjectType{
        name: "QRandomGenerator"
        ModifyFunction{
            signature: "operator()()"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "QRandomGenerator(QRandomGenerator::System)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "QRandomGenerator(QRandomGenerator)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "QRandomGenerator(const unsigned int *, const unsigned int *)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "generate(unsigned int *, unsigned int *)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "QRandomGenerator(const unsigned int *, qsizetype)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "operator=(QRandomGenerator)"
            remove: RemoveFlag.All
        }
        ModifyFunction{
            signature: "securelySeeded()"
            ModifyArgument{
                index: 0
                ReplaceType{
                    modifiedType: "io.qt.core.QRandomGenerator"
                }
                NoNullPointer{
                }
                ConversionRule{
                    codeClass: CodeClass.Native
                    Text{content: "%out = QtJambiAPI::convertNativeToJavaObject(%env, new QRandomGenerator(%in), false, false);"}
                }
            }
        }
    }
    
    FunctionalType{
        name: "QtMessageHandler"
    }
    
    Rejection{
        className: "QUntypedPropertyData::InheritsQUntypedPropertyData"
    }
    
    Rejection{
        className: "QPropertyData::DisableRValueRefs"
    }
    
    Rejection{
        className: "QtPrivate::BindingFunctionVTable"
    }
    
    Rejection{
        className: "QUntypedPropertyBinding::BindingFunctionVTable"
    }
    
    NamespaceType{
        name: "QNativeInterface"
        generate: false
        since: 6
    }
    
    NamespaceType{
        name: "QNativeInterface::Private"
        generate: false
        since: 6
    }
    
    InterfaceType{
        name: "QNativeInterface::QAndroidApplication"
        packageName: "io.qt.core.nativeinterface"
        javaName: "QAndroidApplication"
        ppCondition: "defined(Q_OS_ANDROID) && !defined(Q_OS_ANDROID_EMBEDDED)"
        isNativeInterface: true
        generate: "no-shell"
        ModifyFunction{
            signature: "QAndroidApplication()"
            remove: RemoveFlag.All
        }
        since: [6, 2]
    }
    
    ValueType{
        name: "QHashSeed"
        ModifyFunction{
            signature: "operator size_t() const"
            rename: "seed"
        }
        since: [6, 2]
    }
    
    Rejection{
        className: ""
        functionName: "JNI_CreateJavaVM"
    }
    
    Rejection{
        className: ""
        functionName: "JNI_GetCreatedJavaVMs"
    }
    
    Rejection{
        className: ""
        functionName: "JNI_GetDefaultJavaVMInitArgs"
    }
    
    Rejection{
        className: ""
        functionName: "JNI_OnLoad"
    }
    
    Rejection{
        className: ""
        functionName: "JNI_OnUnload"
    }
    
    Rejection{
        className: ""
        functionName: "qAddPostRoutine"
    }
    
    Rejection{
        className: ""
        functionName: "qAddPreRoutine"
    }
    
    Rejection{
        className: ""
        functionName: "qAppName"
    }
    
    Rejection{
        className: ""
        functionName: "decodeVersion0ArchRequirements"
    }
    
    Rejection{
        className: ""
        functionName: "decodeVersion1ArchRequirements"
    }
    
    Rejection{
        className: ""
        functionName: "is_ident_char"
    }
    
    Rejection{
        className: ""
        functionName: "is_space"
    }
    
    Rejection{
        className: ""
        functionName: "processOpenModeFlags"
    }
    
    Rejection{
        className: ""
        functionName: "qAbort"
    }
    
    Rejection{
        className: ""
        functionName: "qBadAlloc"
    }
    
    Rejection{
        className: ""
        functionName: "static_assert"
    }
    
    Rejection{
        className: ""
        functionName: "qvsnprintf"
    }
    
    Rejection{
        className: ""
        functionName: "qunsetenv"
    }
    
    Rejection{
        className: ""
        functionName: "qt_qnan"
    }
    
    Rejection{
        className: ""
        functionName: "qt_qFindChildren_helper"
    }
    
    Rejection{
        className: ""
        functionName: "qt_qFindChild_helper"
    }
    
    Rejection{
        className: ""
        functionName: "qt_noop"
    }
    
    Rejection{
        className: ""
        functionName: "qt_message_output"
    }
    
    Rejection{
        className: ""
        functionName: "qt_is_nan"
    }
    
    Rejection{
        className: ""
        functionName: "qt_is_inf"
    }
    
    Rejection{
        className: ""
        functionName: "qt_is_finite"
    }
    
    Rejection{
        className: ""
        functionName: "qt_inf"
    }
    
    Rejection{
        className: ""
        functionName: "qt_hash"
    }
    
    Rejection{
        className: ""
        functionName: "qt_fpclassify"
    }
    
    Rejection{
        className: ""
        functionName: "qt_error_string"
    }
    
    Rejection{
        className: ""
        functionName: "qt_custom_file_engine_handler_create"
    }
    
    Rejection{
        className: ""
        functionName: "qt_clang_builtin_available"
    }
    
    Rejection{
        className: ""
        functionName: "qt_check_pointer"
    }
    
    Rejection{
        className: ""
        functionName: "qt_assert"
    }
    
    Rejection{
        className: ""
        functionName: "qt_assert_x"
    }
    
    Rejection{
        className: ""
        functionName: "qt_QMetaEnum_flagDebugOperator"
    }
    
    Rejection{
        className: ""
        functionName: "qt_QMetaEnum_debugOperator"
    }
    
    Rejection{
        className: ""
        functionName: "qtTrId"
    }
    
    Rejection{
        className: ""
        functionName: "qstrnlen"
    }
    
    Rejection{
        className: ""
        functionName: "qstrnicmp"
    }
    
    Rejection{
        className: ""
        functionName: "qstrncpy"
    }
    
    Rejection{
        className: ""
        functionName: "qstrncmp"
    }
    
    Rejection{
        className: ""
        functionName: "qstrlen"
    }
    
    Rejection{
        className: ""
        functionName: "qstricmp"
    }
    
    Rejection{
        className: ""
        functionName: "qstrdup"
    }
    
    Rejection{
        className: ""
        functionName: "qstrcpy"
    }
    
    Rejection{
        className: ""
        functionName: "qstrcmp"
    }
    
    Rejection{
        className: ""
        functionName: "qsnprintf"
    }
    
    Rejection{
        className: ""
        functionName: "qputenv"
    }
    
    Rejection{
        className: ""
        functionName: "qbswap"
    }
    
    Rejection{
        className: ""
        functionName: "qbswap_helper"
    }
    
    Rejection{
        className: ""
        functionName: "qgetenv"
    }
    
    Rejection{
        className: ""
        functionName: "qVersion"
    }
    
    Rejection{
        className: ""
        functionName: "qTzSet"
    }
    
    Rejection{
        className: ""
        functionName: "qTerminate"
    }
    
    Rejection{
        className: ""
        functionName: "qSharedBuild"
    }
    
    Rejection{
        className: ""
        functionName: "qSetRealNumberPrecision"
    }
    
    Rejection{
        className: ""
        functionName: "qSetPadChar"
    }
    
    Rejection{
        className: ""
        functionName: "qSetFieldWidth"
    }
    
    Rejection{
        className: ""
        functionName: "qEnvironmentVariable"
    }
    
    Rejection{
        className: ""
        functionName: "qEnvironmentVariableIntValue"
    }
    
    Rejection{
        className: ""
        functionName: "qEnvironmentVariableIsEmpty"
    }
    
    Rejection{
        className: ""
        functionName: "qEnvironmentVariableIsSet"
    }
    
    Rejection{
        className: ""
        functionName: "qobject_cast"
    }
    
    Rejection{
        className: ""
        functionName: "qobject_iid_cast"
    }
    
    Rejection{
        className: ""
        functionName: "qobject_interface_iid"
    }
    
    Rejection{
        className: ""
        functionName: "qobject_pointer_cast"
    }
    
    Rejection{
        className: ""
        functionName: "qvariant_cast"
    }
    
    Rejection{
        className: ""
        functionName: "qSubOverflow"
    }
    
    Rejection{
        className: ""
        functionName: "qt_ptr_swap"
    }
    
    Rejection{
        className: ""
        functionName: "qt_QMetaEnum_flagDebugOperator_helper"
    }
    
    Rejection{
        className: ""
        functionName: "qbswapFloatHelper"
    }
    
    Rejection{
        className: ""
        functionName: "q_check_ptr"
    }
    
    Rejection{
        className: ""
        functionName: "qWeakPointerFromVariant"
    }
    
    Rejection{
        className: ""
        functionName: "qWeakPointerCast"
    }
    
    Rejection{
        className: ""
        functionName: "qTokenize"
    }
    
    Rejection{
        className: ""
        functionName: "qToUnderlying"
    }
    
    Rejection{
        className: ""
        functionName: "qToUnaligned"
    }
    
    Rejection{
        className: ""
        functionName: "qToStringViewIgnoringNull"
    }
    
    Rejection{
        className: ""
        functionName: "qToLittleEndian"
    }
    
    Rejection{
        className: ""
        functionName: "qToBigEndian"
    }
    
    Rejection{
        className: ""
        functionName: "qThreadStorage_setLocalData"
    }
    
    Rejection{
        className: ""
        functionName: "qThreadStorage_localData_const"
    }
    
    Rejection{
        className: ""
        functionName: "qThreadStorage_localData"
    }
    
    Rejection{
        className: ""
        functionName: "qThreadStorage_deleteData"
    }
    
    Rejection{
        className: ""
        functionName: "qSharedPointerObjectCast"
    }
    
    Rejection{
        className: ""
        functionName: "qSharedPointerFromVariant"
    }
    
    Rejection{
        className: ""
        functionName: "qSharedPointerDynamicCast"
    }
    
    Rejection{
        className: ""
        functionName: "qSharedPointerConstCast"
    }
    
    Rejection{
        className: ""
        functionName: "qSharedPointerCast"
    }
    
    Rejection{
        className: ""
        functionName: "qScopeGuard"
    }
    
    Rejection{
        className: ""
        functionName: "qMulOverflow"
    }
    
    Rejection{
        className: ""
        functionName: "qPointerFromVariant"
    }
    
    Rejection{
        className: ""
        functionName: "qMakeStaticByteArrayMatcher"
    }
    
    Rejection{
        className: ""
        functionName: "qMakePair"
    }
    
    Rejection{
        className: ""
        functionName: "qLoadPlugin"
    }
    
    Rejection{
        className: ""
        functionName: "qLoadPlugin1"
    }
    
    Rejection{
        className: ""
        functionName: "qHashRangeCommutative"
    }
    
    Rejection{
        className: ""
        functionName: "qHashRange"
    }
    
    Rejection{
        className: ""
        functionName: "qHashMultiCommutative"
    }
    
    Rejection{
        className: ""
        functionName: "qHashMulti"
    }
    
    Rejection{
        className: ""
        functionName: "qHashEquals"
    }
    
    Rejection{
        className: ""
        functionName: "qGetPtrHelper"
    }
    
    Rejection{
        className: ""
        functionName: "qFromUnaligned"
    }
    
    Rejection{
        className: ""
        functionName: "qFromLittleEndian"
    }
    
    Rejection{
        className: ""
        functionName: "qFromBigEndian"
    }
    
    Rejection{
        className: ""
        functionName: "qAddOverflow"
    }
    
    Rejection{
        className: ""
        functionName: "qAsConst"
    }
    
    Rejection{
        className: ""
        functionName: "genericHash"
    }
    
    Rejection{
        className: ""
        functionName: "erase_if"
    }
    
    Rejection{
        className: ""
        functionName: "erase"
    }
    
    Rejection{
        className: ""
        functionName: "qDeleteInEventHandler"
    }
    
    Rejection{
        className: ""
        functionName: "qFloatFromFloat16"
    }
    
    Rejection{
        className: ""
        functionName: "qFloatToFloat16"
    }
    
    Rejection{
        className: ""
        functionName: "qGetBindingStorage"
    }
    
    Rejection{
        className: ""
        functionName: "qHashBits"
    }
    
    Rejection{
        className: ""
        functionName: "qInstallMessageHandler"
    }
    
    Rejection{
        className: ""
        functionName: "qMallocAligned"
    }
    
    Rejection{
        className: ""
        functionName: "qMetaTypeTypeInternal"
    }
    
    Rejection{
        className: ""
        functionName: "qMkTime"
    }
    
    Rejection{
        className: ""
        functionName: "qReallocAligned"
    }
    
    Rejection{
        className: ""
        functionName: "qRemovePostRoutine"
    }
    
    Rejection{
        className: ""
        functionName: "qAtomicAssign"
    }
    
    Rejection{
        className: ""
        functionName: "qAtomicDetach"
    }
    
    Rejection{
        className: ""
        functionName: "qDeleteAll"
    }
    
    Rejection{
        className: ""
        functionName: "qExchange"
    }
    
    Rejection{
        className: ""
        functionName: "qPluginArchRequirements"
    }
    
    Rejection{
        className: ""
        functionName: "qFreeAligned"
    }
    
    Rejection{
        className: ""
        functionName: "qt_register_signal_spy_callbacks"
    }
    
    Rejection{
        className: ""
        functionName: "qSwap"
    }
    
    Rejection{
        className: ""
        functionName: "qErrnoWarning"
    }
    
    Rejection{
        className: ""
        functionName: "qSetMessagePattern"
    }
    
    Rejection{
        className: ""
        functionName: "qFormatLogMessage"
    }
    
    GlobalFunction{
        signature: "qCompress(QByteArray, int)"
        targetType: "QByteArray"
    }
    
    GlobalFunction{
        signature: "qUncompress(QByteArray)"
        targetType: "QByteArray"
    }
    
    GlobalFunction{
        signature: "qChecksum(QByteArrayView, Qt::ChecksumType)"
        targetType: "QByteArrayView"
    }
    
    GlobalFunction{
        signature: "qChecksum(const char*, qsizetype, Qt::ChecksumType)"
        remove: RemoveFlag.All
    }
    
    GlobalFunction{
        signature: "qUncompress(const uchar*, qsizetype)"
        remove: RemoveFlag.All
    }
    
    GlobalFunction{
        signature: "qCompress(const uchar*, qsizetype, int)"
        remove: RemoveFlag.All
    }
    
    GlobalFunction{
        signature: "qHash(QPointF, QHashDummyValue, hash_type)"
        remove: RemoveFlag.All
    }
    
    GlobalFunction{
        signature: "qFuzzyIsNull(qfloat16)"
        remove: RemoveFlag.All
    }
    
    GlobalFunction{
        signature: "qFuzzyCompare(qfloat16, qfloat16)"
        remove: RemoveFlag.All
    }
    
    GlobalFunction{
        signature: "qFpClassify(qfloat16)"
        remove: RemoveFlag.All
    }
    
    GlobalFunction{
        signature: "qIntCast(qfloat16)"
        remove: RemoveFlag.All
    }
    
    GlobalFunction{
        signature: "qIsFinite(qfloat16)"
        remove: RemoveFlag.All
    }
    
    GlobalFunction{
        signature: "qIsInf(qfloat16)"
        remove: RemoveFlag.All
    }
    
    GlobalFunction{
        signature: "qIsNaN(qfloat16)"
        remove: RemoveFlag.All
    }

    GlobalFunction{
        signature: "qSqrt(qfloat16)"
        remove: RemoveFlag.All
        since: [6,5]
    }

    GlobalFunction{
        signature: "qHypot(qfloat16, qfloat16)"
        remove: RemoveFlag.All
        since: [6,5]
    }
    
    GlobalFunction{
        signature: "qIsNull(qfloat16)"
        remove: RemoveFlag.All
    }
    
    GlobalFunction{
        signature: "qRound(qfloat16)"
        remove: RemoveFlag.All
    }
    
    GlobalFunction{
        signature: "qRound64(qfloat16)"
        remove: RemoveFlag.All
    }
    
    GlobalFunction{
        signature: "qPopulationCount(long unsigned int)"
        remove: RemoveFlag.All
    }
    
    GlobalFunction{
        signature: "qPopulationCount(quint8)"
        targetType: "QtAlgorithms"
    }
    
    GlobalFunction{
        signature: "qPopulationCount(quint16)"
        targetType: "QtAlgorithms"
    }
    
    GlobalFunction{
        signature: "qPopulationCount(quint32)"
        targetType: "QtAlgorithms"
    }
    
    GlobalFunction{
        signature: "qPopulationCount(quint64)"
        targetType: "QtAlgorithms"
    }
    
    GlobalFunction{
        signature: "qCountLeadingZeroBits(unsigned long)"
        remove: RemoveFlag.All
    }
    
    GlobalFunction{
        signature: "qCountLeadingZeroBits(quint16)"
        targetType: "QtAlgorithms"
    }
    
    GlobalFunction{
        signature: "qCountLeadingZeroBits(quint32)"
        targetType: "QtAlgorithms"
    }
    
    GlobalFunction{
        signature: "qCountLeadingZeroBits(quint8)"
        targetType: "QtAlgorithms"
    }
    
    GlobalFunction{
        signature: "qCountLeadingZeroBits(quint64)"
        targetType: "QtAlgorithms"
    }
    
    GlobalFunction{
        signature: "qCountTrailingZeroBits(unsigned long)"
        remove: RemoveFlag.All
    }
    
    GlobalFunction{
        signature: "qCountTrailingZeroBits(quint16)"
        targetType: "QtAlgorithms"
    }
    
    GlobalFunction{
        signature: "qCountTrailingZeroBits(quint32)"
        targetType: "QtAlgorithms"
    }
    
    GlobalFunction{
        signature: "qCountTrailingZeroBits(quint8)"
        targetType: "QtAlgorithms"
    }
    
    GlobalFunction{
        signature: "qCountTrailingZeroBits(quint64)"
        targetType: "QtAlgorithms"
    }
    
    GlobalFunction{
        signature: "qFastCos(qreal)"
        targetType: "QtMath"
    }
    
    GlobalFunction{
        signature: "qFastSin(qreal)"
        targetType: "QtMath"
    }
    
    GlobalFunction{
        signature: "qNextPowerOfTwo(qint32)"
        targetType: "QtMath"
    }
    
    GlobalFunction{
        signature: "qNextPowerOfTwo(qint64)"
        targetType: "QtMath"
    }
    
    GlobalFunction{
        signature: "qDegreesToRadians(double)"
        targetType: "QtMath"
    }
    
    GlobalFunction{
        signature: "qDegreesToRadians(float)"
        targetType: "QtMath"
    }
    
    GlobalFunction{
        signature: "qRadiansToDegrees(double)"
        targetType: "QtMath"
    }
    
    GlobalFunction{
        signature: "qRadiansToDegrees(float)"
        targetType: "QtMath"
    }
    
    GlobalFunction{
        signature: "qIsNaN(double)"
        targetType: "QtNumeric"
    }
    
    GlobalFunction{
        signature: "qIsInf(double)"
        targetType: "QtNumeric"
    }
    
    GlobalFunction{
        signature: "qIsFinite(double)"
        targetType: "QtNumeric"
    }
    
    GlobalFunction{
        signature: "qFpClassify(double)"
        targetType: "QtNumeric"
    }
    
    GlobalFunction{
        signature: "qFloatDistance(double,double)"
        targetType: "QtNumeric"
    }
    
    GlobalFunction{
        signature: "qIsNaN(float)"
        targetType: "QtNumeric"
    }
    
    GlobalFunction{
        signature: "qIsInf(float)"
        targetType: "QtNumeric"
    }
    
    GlobalFunction{
        signature: "qIsFinite(float)"
        targetType: "QtNumeric"
    }
    
    GlobalFunction{
        signature: "qFpClassify(float)"
        targetType: "QtNumeric"
    }
    
    GlobalFunction{
        signature: "qFloatDistance(float,float)"
        targetType: "QtNumeric"
    }
    
    GlobalFunction{
        signature: "qInf()"
        targetType: "QtNumeric"
    }
    
    GlobalFunction{
        signature: "qQNaN()"
        targetType: "QtNumeric"
    }

    GlobalFunction{
        signature: "qt_snan()"
        remove: RemoveFlag.All
        since: [6,5]
    }

    GlobalFunction{
        signature: "qSNaN()"
        targetType: "QtNumeric"
        since: [6,5]
    }
    
    GlobalFunction{
        signature: "qIsFinite<T>(T)"
        remove: RemoveFlag.All
    }

    GlobalFunction{
        signature: "qRegisterMetaType(QMetaType)"
        remove: RemoveFlag.All
        since: [6,5]
    }
    
    GlobalFunction{
        signature: "qIsInf<T>(T)"
        remove: RemoveFlag.All
    }
    
    GlobalFunction{
        signature: "qIsNaN<T>(T)"
        remove: RemoveFlag.All
    }

    GlobalFunction{
        signature: "qFuzzyCompare(double, double)"
        targetType: "QtGlobal"
    }
    
    GlobalFunction{
        signature: "qFuzzyCompare(double, double)"
        targetType: "QtGlobal"
    }
    
    GlobalFunction{
        signature: "qFuzzyIsNull(double)"
        targetType: "QtGlobal"
    }
    
    GlobalFunction{
        signature: "qFuzzyCompare(float, float)"
        targetType: "QtGlobal"
    }
    
    GlobalFunction{
        signature: "qFuzzyIsNull(float)"
        targetType: "QtGlobal"
    }
    
    GlobalFunction{
        signature: "qIntCast(float)"
        targetType: "QtGlobal"
    }
    
    GlobalFunction{
        signature: "qIsNull(float)"
        targetType: "QtGlobal"
    }
    
    GlobalFunction{
        signature: "qIntCast(double)"
        targetType: "QtGlobal"
    }
    
    GlobalFunction{
        signature: "qIsNull(double)"
        targetType: "QtGlobal"
    }
    
    GlobalFunction{
        signature: "qRound64(float)"
        targetType: "QtGlobal"
    }
    
    GlobalFunction{
        signature: "qRound(float)"
        targetType: "QtGlobal"
    }
    
    GlobalFunction{
        signature: "qRound(double)"
        targetType: "QtGlobal"
    }
    
    GlobalFunction{
        signature: "qRound64(double)"
        targetType: "QtGlobal"
    }
    
    GlobalFunction{
        signature: "qMin<T,U>(T, U)"
        remove: RemoveFlag.All
    }
    
    GlobalFunction{
        signature: "qMax<T,U>(T, U)"
        remove: RemoveFlag.All
    }

    GlobalFunction{
        signature: "qBound<T, U>(const T&, const T&, const U&)"
        remove: RemoveFlag.All
        since: [6,5]
    }

    GlobalFunction{
        signature: "qBound<T, U>(const T&, const U&, const T&)"
        remove: RemoveFlag.All
        since: [6,5]
    }

    GlobalFunction{
        signature: "qBound<T, U>(const U&, const T&, const T&)"
        remove: RemoveFlag.All
        since: [6,5]
    }

    GlobalFunction{
        signature: "convertDoubleTo<T>(double, T*, bool)"
        remove: RemoveFlag.All
        since: [6,5]
    }

    GlobalFunction{
        signature: "qt_saturate<To, From>(From)"
        remove: RemoveFlag.All
        since: [6,5]
    }

    GlobalFunction{
        signature: "add_overflow<T, V2>(T, std::integral_constant<T,V2>, T*)"
        remove: RemoveFlag.All
        since: [6,5]
    }

    GlobalFunction{
        signature: "add_overflow<T>(T, T, T*)"
        remove: RemoveFlag.All
        since: [6,5]
    }

    GlobalFunction{
        signature: "add_overflow<V2, T>(T, T*)"
        remove: RemoveFlag.All
        since: [6,5]
    }

    GlobalFunction{
        signature: "mul_overflow<T, V2>(T, std::integral_constant<T,V2>, T*)"
        remove: RemoveFlag.All
        since: [6,5]
    }

    GlobalFunction{
        signature: "mul_overflow<T>(T, T, T*)"
        remove: RemoveFlag.All
        since: [6,5]
    }

    GlobalFunction{
        signature: "mul_overflow<V2, T>(T, T*)"
        remove: RemoveFlag.All
        since: [6,5]
    }

    GlobalFunction{
        signature: "sub_overflow<T, V2>(T, std::integral_constant<T,V2>, T*)"
        remove: RemoveFlag.All
        since: [6,5]
    }

    GlobalFunction{
        signature: "sub_overflow<T>(T, T, T*)"
        remove: RemoveFlag.All
        since: [6,5]
    }

    GlobalFunction{
        signature: "sub_overflow<V2, T>(T, T*)"
        remove: RemoveFlag.All
        since: [6,5]
    }

    GlobalFunction{
        signature: "qBound<T>(T, T, T)"
        targetType: "QtGlobal"
        Instantiation{
            Argument{
                type: "qint8"
            }
        }
        Instantiation{
            Argument{
                type: "qint16"
            }
        }
        Instantiation{
            Argument{
                type: "qint32"
            }
        }
        Instantiation{
            Argument{
                type: "qint64"
            }
        }
        Instantiation{
            Argument{
                type: "double"
            }
        }
        Instantiation{
            Argument{
                type: "float"
            }
        }
    }
    
    GlobalFunction{
        signature: "qMin<T>(T, T)"
        targetType: "QtGlobal"
        Instantiation{
            Argument{
                type: "qint8"
            }
        }
        Instantiation{
            Argument{
                type: "qint16"
            }
        }
        Instantiation{
            Argument{
                type: "qint32"
            }
        }
        Instantiation{
            Argument{
                type: "qint64"
            }
        }
        Instantiation{
            Argument{
                type: "double"
            }
        }
        Instantiation{
            Argument{
                type: "float"
            }
        }
    }
    
    GlobalFunction{
        signature: "qMax<T>(T, T)"
        targetType: "QtGlobal"
        Instantiation{
            Argument{
                type: "qint8"
            }
        }
        Instantiation{
            Argument{
                type: "qint16"
            }
        }
        Instantiation{
            Argument{
                type: "qint32"
            }
        }
        Instantiation{
            Argument{
                type: "qint64"
            }
        }
        Instantiation{
            Argument{
                type: "double"
            }
        }
        Instantiation{
            Argument{
                type: "float"
            }
        }
    }
    
    GlobalFunction{
        signature: "qAbs<T>(T)"
        targetType: "QtGlobal"
        Instantiation{
            Argument{
                type: "qint8"
            }
        }
        Instantiation{
            Argument{
                type: "qint16"
            }
        }
        Instantiation{
            Argument{
                type: "qint32"
            }
        }
        Instantiation{
            Argument{
                type: "qint64"
            }
        }
        Instantiation{
            Argument{
                type: "double"
            }
        }
        Instantiation{
            Argument{
                type: "float"
            }
        }
    }
    
    GlobalFunction{
        signature: "qAcos<T>(T)"
        targetType: "QtMath"
        Instantiation{
            Argument{
                type: "double"
            }
            Argument{
                type: "double"
            }
        }
        Instantiation{
            Argument{
                type: "float"
            }
            Argument{
                type: "float"
            }
        }
    }
    
    GlobalFunction{
        signature: "qAsin<T>(T)"
        targetType: "QtMath"
        Instantiation{
            Argument{
                type: "double"
            }
            Argument{
                type: "double"
            }
        }
        Instantiation{
            Argument{
                type: "float"
            }
            Argument{
                type: "float"
            }
        }
    }
    
    GlobalFunction{
        signature: "qAtan2<T1,T2>(T1,T2)"
        targetType: "QtMath"
        Instantiation{
            Argument{
                type: "double"
            }
            Argument{
                type: "double"
            }
            Argument{
                type: "double"
            }
        }
        Instantiation{
            Argument{
                type: "float"
            }
            Argument{
                type: "float"
            }
            Argument{
                type: "float"
            }
        }
    }
    
    GlobalFunction{
        signature: "qPow<T1,T2>(T1,T2)"
        targetType: "QtMath"
        Instantiation{
            Argument{
                type: "double"
            }
            Argument{
                type: "double"
            }
            Argument{
                type: "double"
            }
        }
        Instantiation{
            Argument{
                type: "float"
            }
            Argument{
                type: "float"
            }
            Argument{
                type: "float"
            }
        }
    }
    
    GlobalFunction{
        signature: "qAtan<T>(T)"
        targetType: "QtMath"
        Instantiation{
            Argument{
                type: "double"
            }
            Argument{
                type: "double"
            }
        }
        Instantiation{
            Argument{
                type: "float"
            }
            Argument{
                type: "float"
            }
        }
    }
    
    GlobalFunction{
        signature: "qCos<T>(T)"
        targetType: "QtMath"
        Instantiation{
            Argument{
                type: "double"
            }
            Argument{
                type: "double"
            }
        }
        Instantiation{
            Argument{
                type: "float"
            }
            Argument{
                type: "float"
            }
        }
    }
    
    GlobalFunction{
        signature: "qSin<T>(T)"
        targetType: "QtMath"
        Instantiation{
            Argument{
                type: "double"
            }
            Argument{
                type: "double"
            }
        }
        Instantiation{
            Argument{
                type: "float"
            }
            Argument{
                type: "float"
            }
        }
    }
    
    GlobalFunction{
        signature: "qTan<T>(T)"
        targetType: "QtMath"
        Instantiation{
            Argument{
                type: "double"
            }
            Argument{
                type: "double"
            }
        }
        Instantiation{
            Argument{
                type: "float"
            }
            Argument{
                type: "float"
            }
        }
    }
    
    GlobalFunction{
        signature: "qSqrt<T>(T)"
        targetType: "QtMath"
        Instantiation{
            Argument{
                type: "double"
            }
            Argument{
                type: "double"
            }
        }
        Instantiation{
            Argument{
                type: "float"
            }
            Argument{
                type: "float"
            }
        }
    }
    
    GlobalFunction{
        signature: "qExp<T>(T)"
        targetType: "QtMath"
        Instantiation{
            Argument{
                type: "double"
            }
            Argument{
                type: "double"
            }
        }
        Instantiation{
            Argument{
                type: "float"
            }
            Argument{
                type: "float"
            }
        }
    }
    
    GlobalFunction{
        signature: "qFabs<T>(T)"
        targetType: "QtMath"
        Instantiation{
            Argument{
                type: "double"
            }
            Argument{
                type: "double"
            }
        }
        Instantiation{
            Argument{
                type: "float"
            }
            Argument{
                type: "float"
            }
        }
    }
    
    GlobalFunction{
        signature: "qCeil<T>(T)"
        targetType: "QtMath"
        Instantiation{
            Argument{
                type: "double"
            }
            Argument{
                type: "double"
            }
        }
        Instantiation{
            Argument{
                type: "float"
            }
            Argument{
                type: "float"
            }
        }
    }
    
    GlobalFunction{
        signature: "qFloor<T>(T)"
        targetType: "QtMath"
        Instantiation{
            Argument{
                type: "double"
            }
            Argument{
                type: "double"
            }
        }
        Instantiation{
            Argument{
                type: "float"
            }
            Argument{
                type: "float"
            }
        }
    }
    
    GlobalFunction{
        signature: "qLn<T>(T)"
        targetType: "QtMath"
        Instantiation{
            Argument{
                type: "double"
            }
            Argument{
                type: "double"
            }
        }
        Instantiation{
            Argument{
                type: "float"
            }
            Argument{
                type: "float"
            }
        }
    }
    
    GlobalFunction{
        signature: "qHypot<F,Fs...>(F, Fs...)"
        remove: RemoveFlag.All
    }
    
    GlobalFunction{
        signature: "qHypot<Tx,Ty,Tz>(Tx, Ty, Tz)"
        remove: RemoveFlag.All
    }

    GlobalFunction{
        signature: "qHypot<T>(T, qfloat16)"
        remove: RemoveFlag.All
        since: [6,5]
    }

    GlobalFunction{
        signature: "qHypot<T>(qfloat16, T)"
        remove: RemoveFlag.All
        since: [6,5]
    }
    
    GlobalFunction{
        signature: "qHypot<Tx,Ty>(Tx, Ty)"
        targetType: "QtMath"
        Instantiation{
            Argument{
                type: "double"
            }
            Argument{
                type: "double"
            }
            Argument{
                type: "double"
            }
        }
        Instantiation{
            Argument{
                type: "float"
            }
            Argument{
                type: "float"
            }
            Argument{
                type: "float"
            }
        }
    }
    
    GlobalFunction{
        signature: "qGlobalQHashSeed()"
        targetType: "Qt"
    }
    
    GlobalFunction{
        signature: "qSetGlobalQHashSeed(int)"
        targetType: "Qt"
    }
    
    GlobalFunction{
        signature: "qDegreesToRadians(long double)"
        remove: RemoveFlag.All
    }
    
    GlobalFunction{
        signature: "qRadiansToDegrees(long double)"
        remove: RemoveFlag.All
    }
    
    GlobalFunction{
        signature: "qNextPowerOfTwo(quint32)"
        remove: RemoveFlag.All
    }
    
    GlobalFunction{
        signature: "qNextPowerOfTwo(quint64)"
        remove: RemoveFlag.All
    }
    
    GlobalFunction{
        signature: "qAcos(qreal)"
        targetType: "QtMath"
        until: [5, 15]
    }
    
    GlobalFunction{
        signature: "qAsin(qreal)"
        targetType: "QtMath"
        until: [5, 15]
    }
    
    GlobalFunction{
        signature: "qAtan(qreal)"
        targetType: "QtMath"
        until: [5, 15]
    }
    
    GlobalFunction{
        signature: "qAtan2(qreal, qreal)"
        targetType: "QtMath"
        until: [5, 15]
    }
    
    GlobalFunction{
        signature: "qPow(qreal, qreal)"
        targetType: "QtMath"
        until: [5, 15]
    }
    
    GlobalFunction{
        signature: "qCeil(qreal)"
        targetType: "QtMath"
        until: [5, 15]
    }
    
    GlobalFunction{
        signature: "qCos(qreal)"
        targetType: "QtMath"
        until: [5, 15]
    }
    
    GlobalFunction{
        signature: "qExp(qreal)"
        targetType: "QtMath"
        until: [5, 15]
    }
    
    GlobalFunction{
        signature: "qFabs(qreal)"
        targetType: "QtMath"
        until: [5, 15]
    }
    
    GlobalFunction{
        signature: "qFloor(qreal)"
        targetType: "QtMath"
        until: [5, 15]
    }
    
    GlobalFunction{
        signature: "qLn(qreal)"
        targetType: "QtMath"
        until: [5, 15]
    }
    
    GlobalFunction{
        signature: "qSin(qreal)"
        targetType: "QtMath"
        until: [5, 15]
    }
    
    GlobalFunction{
        signature: "qSqrt(qreal)"
        targetType: "QtMath"
        until: [5, 15]
    }
    
    GlobalFunction{
        signature: "qTan(qreal)"
        targetType: "QtMath"
        until: [5, 15]
    }
    
    GlobalFunction{
        signature: "qrand()"
        targetType: "QtGlobal"
        until: [5, 15]
    }
    
    GlobalFunction{
        signature: "qsrand(uint)"
        targetType: "QtGlobal"
        until: [5, 15]
    }
    
    GlobalFunction{
        signature: "qChecksum(const char*, unsigned int)"
        remove: RemoveFlag.All
        until: [5, 15]
    }
    
    GlobalFunction{
        signature: "qChecksum(const char*, unsigned int, Qt::ChecksumType)"
        remove: RemoveFlag.All
        until: [5, 15]
    }
    
    GlobalFunction{
        signature: "qCompress(const uchar*, int, int)"
        remove: RemoveFlag.All
        until: [5, 15]
    }
    
    GlobalFunction{
        signature: "qUncompress(const uchar*, int)"
        remove: RemoveFlag.All
        until: [5, 15]
    }
    
    HeaderType{
        name: "QtAlgorithms"
    }
    
    HeaderType{
        name: "QtGlobal"
        InjectCode{
            target: CodeClass.Java
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QtGlobal_5_"
                quoteBeforeLine: "}// class"
                until: 5
            }
            ImportFile{
                name: ":/io/qtjambi/generator/typesystem/QtJambiCore.java"
                quoteAfterLine: "class QtGlobal_6_"
                quoteBeforeLine: "}// class"
                since: 6
            }
        }
    }
    
    HeaderType{
        name: "QtNumeric"
    }
    
    HeaderType{
        name: "QtMath"
    }

    Rejection{
        className: "QIterable"
    }

    Rejection{
        className: "QSequentialIterable"
    }

    Rejection{
        className: "QAssociativeIterable"
    }
    
    SuppressedWarning{text: "WARNING(Preprocessor) :: No such file or directory: *"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: signature 'operator<<(char16_t)' for function modification in 'QDebug' not found.*"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: signature 'operator<<(char32_t)' for function modification in 'QDebug' not found.*"}
    SuppressedWarning{text: "WARNING(JavaGenerator) :: No ==/!= operator found for value type QHashSeed."}
    SuppressedWarning{text: "WARNING(JavaGenerator) :: No ==/!= operator found for value type QDebug."}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type 'QUtf8StringView'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type 'QAnyStringView'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type 'QLatin1StringView'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type 'QTextStreamFunction'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type 'QTextStreamManipulator'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type 'QDebug::Latin1Content'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type 'QAbstractFileEngine::ExtensionOption const\\*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type 'QAbstractFileEngine::Iterator\\*'"}
    
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QVariantAnimation::registerInterpolator', unmatched parameter type '*Interpolator'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type 'Qt::Initialization'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type 'std::*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type '*Private\\*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type '*Private const\\*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type '*Private&'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type 'QMetaObject'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type 'const QMetaMethod&'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type 'FILE\\*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type 'QByteArray::Data\\*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type 'QByteArrayDataPtr'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type 'QTSMFC'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type 'QTSMFI'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type 'QDataStream::ByteOrder'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type 'Data::AllocationOptions'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type 'QJsonValueRef'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type '*QJsonArray::const_iterator*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type '*QJsonArray::iterator*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping 'QJsonArray::*' unmatched *type '*iterator'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type '*QJsonObject::const_iterator*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type '*QJsonObject::iterator*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type 'QJsonPrivate::Data\\*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type 'const QMimeTypePrivate&'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: visibility of function '*' modified in class '*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: hiding of function '*' in class '*'"}
    SuppressedWarning{text: "WARNING(CppImplGenerator) :: protected function '*' in final class '*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type 'QPointer<*>'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type 'QVector<*>'"}
    SuppressedWarning{text: "* private virtual function '*' in 'QAbstractListModel'"}
    SuppressedWarning{text: "* private virtual function '*' in 'QAbstractTableModel'"}
    SuppressedWarning{text: "* private virtual function '*' in 'QListWidget'"}
    SuppressedWarning{text: "* private virtual function '*' in 'QTreeWidget'"}
    SuppressedWarning{text: "* private virtual function '*' in 'QFontDialog'"}
    SuppressedWarning{text: "* private virtual function '*' in 'QTableWidget'"}
    SuppressedWarning{text: "* private virtual function '*' in 'QTextCodecPlugin'"}
    SuppressedWarning{text: "* private virtual function '*' in 'QSaveFile'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QFutureWatcherBase::futureInterface', unmatched return type 'QFutureInterfaceBase&'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QFutureWatcherBase::futureInterface', unmatched return type 'const QFutureInterfaceBase&'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QFutureWatcher::futureInterface', unmatched return type 'QFutureInterfaceBase&'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QFutureWatcher::futureInterface', unmatched return type 'const QFutureInterfaceBase&'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: unknown operator 'T'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QFuture::constBegin*', unmatched return type 'const_iterator'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QFuture::end*', unmatched return type 'const_iterator'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QFuture::constEnd*', unmatched return type 'const_iterator'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QFuture::QFuture', unmatched parameter type 'QFutureInterface<T>*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QFuture::begin*', unmatched return type 'const_iterator'"}
    SuppressedWarning{text: "WARNING(Parser) :: ** WARNING scope not found for function definition: 'QtPrivate::IsMetaTypePair<T,true>::registerConverter' - definition *ignored*"}
    SuppressedWarning{text: "WARNING(Parser) :: ** WARNING scope not found for function definition: 'QFuture<void>::operator=' - definition *ignored*"}
    SuppressedWarning{text: "WARNING(Parser) :: ** WARNING scope not found for function definition: 'QFutureInterface<void>::future' - definition *ignored*"}
    SuppressedWarning{text: "WARNING(Parser) :: ** WARNING scope not found for function definition: 'QFutureWatcher<void>::setFuture' - definition *ignored*"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: unmatched enum ~0u"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: unhandled enum value: ~0u in Qt::GestureType"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: signature 'mapped(QWidget*)' for function modification in 'QSignalMapper' not found. Possible candidates: mapped(QObject*) in QSignalMapper, mapped(QString) in QSignalMapper, mapped(int) in QSignalMapper"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: signature 'mapping(QWidget*)const' for function modification in 'QSignalMapper' not found. Possible candidates: mapping(QObject*)const in QSignalMapper, mapping(QString)const in QSignalMapper, mapping(int)const in QSignalMapper"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: signature 'setMapping(QObject*,QWidget*)' for function modification in 'QSignalMapper' not found. Possible candidates: setMapping(QObject*,QObject*) in QSignalMapper, setMapping(QObject*,QString) in QSignalMapper, setMapping(QObject*,int) in QSignalMapper"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function *, unmatched parameter type 'QWidget*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: namespace '*' does not have a type entry"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: type 'JObjectWrapper' is specified in typesystem, but not defined. This could potentially lead to compilation errors."}
    SuppressedWarning{text: "WARNING() :: Duplicate type entry: 'QXmlStreamReader::Error'"}
    SuppressedWarning{text: "WARNING() :: Duplicate type entry: 'QXmlStreamReader::TokenType'"}
    SuppressedWarning{text: "WARNING() :: Duplicate type entry: 'QXmlStreamReader::ReadElementTextBehaviour'"}
    SuppressedWarning{text: "WARNING() :: Duplicate type entry: 'QXmlStreamAttribute'"}
    SuppressedWarning{text: "WARNING() :: Duplicate type entry: 'QXmlStreamAttributes'"}
    SuppressedWarning{text: "WARNING() :: Duplicate type entry: 'QXmlStreamNamespaceDeclaration'"}
    SuppressedWarning{text: "WARNING() :: Duplicate type entry: 'QXmlStreamNotationDeclaration'"}
    SuppressedWarning{text: "WARNING() :: Duplicate type entry: 'QXmlStreamEntityDeclaration'"}
    SuppressedWarning{text: "WARNING() :: Duplicate type entry: 'QXmlStreamReader'"}
    SuppressedWarning{text: "WARNING() :: Duplicate type entry: 'QXmlStreamWriter'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QJsonDocument::QJsonDocument', unmatched parameter type '*QJsonPrivate::Data*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QJsonValue::QJsonValue', unmatched parameter type '*QJsonPrivate::Data*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QJsonArray::QJsonArray', unmatched parameter type '*QJsonPrivate::Data*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: type * is specified in typesystem, but not defined. This could potentially lead to compilation errors."}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: enum * is specified in typesystem, but not declared"}
    SuppressedWarning{text: "WARNING(Parser) :: ** WARNING scope not found for function definition: '*' - definition *ignored*"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function '*', unmatched parameter type '*QListData::*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function '*', unmatched parameter type '*QtPrivate::*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QPair::*', unmatched parameter type '*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: isFunctionPointer: *"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function '*', unmatched parameter type '*QAbstractNativeEventFilter*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: template baseclass 'QListSpecialMethods<T>' of 'List' is not known"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: signature 'parent()const' for function modification in '*' not found. Possible candidates: parent(QModelIndex)const in *"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: signature 'operator<(QCollatorSortKey,QCollatorSortKey)' for function modification in 'QCollatorSortKey' not found. Possible candidates: operator<(QCollatorSortKey) in QCollatorSortKey"}
    SuppressedWarning{text: "WARNING(Parser) :: scope not found for function definition: 'QListSpecialMethods*::*' - definition *ignored*"}
    SuppressedWarning{text: "WARNING(Parser) :: scope not found for function definition: 'QtPrivate::IsMetaTypePair*::registerConverter' - definition *ignored*"}
    SuppressedWarning{text: "WARNING(Parser) :: scope not found for function definition: 'QSharedPointer*::toWeakRef' - definition *ignored*"}
    SuppressedWarning{text: "WARNING(Parser) :: scope not found for function definition: 'QFutureInterface*::future' - definition *ignored*"}
    SuppressedWarning{text: "WARNING(Parser) :: scope not found for function definition: 'QFutureWatcher*::setFuture' - definition *ignored*"}
    SuppressedWarning{text: "WARNING(Parser) :: scope not found for function definition: 'QVectorSpecialMethods<QString>::*' - definition *ignored*"}
    SuppressedWarning{text: "WARNING(Parser) :: scope not found for symbol: QMetaTypeForType<T>::*"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: enum 'ObjectDeletionPolicy' does not have a type entry or is not an enum"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: enum 'InternalFunction' does not have a type entry or is not an enum"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QMap::*', *"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QHash::*', *"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QMultiMap::*', *"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QMultiHash::*', *"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QVector::*', *"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QSet::*', *"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QLinkedList::*', *"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QList::*', *"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping field 'LinkedList$Iterator::i' with unmatched type 'Node'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping field 'List$Iterator::i' with unmatched type 'Node'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QDBusReply::*', unmatched *type '*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping field 'QIterator::i' with unmatched type 'Node'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: signature 'operator*()' for function modification in '*::const_iterator' not found. Possible candidates: *"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: signature 'operator++()' for function modification in '*::const_iterator' not found. Possible candidates: *"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: signature 'operator--()' for function modification in '*::const_iterator' not found. Possible candidates: *"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: signature '*::iterator()' for function modification in '*::iterator' not found. Possible candidates: *"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: signature '*::iterator(*::iterator)' for function modification in '*::iterator' not found. Possible candidates: *"}
    SuppressedWarning{text: "WARNING(Preprocessor) :: qtjambi_masterinclude.h:*  <*/*>: No such file or directory"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: Final class 'QAbstractAnimation' set to non-final, as it is extended by other classes"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: signature 'beginEntryList*' for function modification in 'QAbstractFileEngine' not found. Possible candidates:*"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function '*', unmatched *type '*QCborMap::Iterator*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function '*', unmatched *type '*QCborArray::iterator*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function '*', unmatched *type '*QCborArray::Iterator*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function '*', unmatched *type '*QJsonArray::iterator*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QPair*', unmatched *type '*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: enum 'QCborNegativeInteger' does not have a type entry or is not an enum"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function '*', unmatched *type 'QCborNegativeInteger*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QMetaType::*', unmatched *type '*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: enum 'QMetaType::TypeFlag' does not have a type entry or is not an enum"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function '*', unmatched *type 'QJsonValuePtr'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function '*', unmatched *type 'const QJsonObject::iterator&'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * 'QSysInfo::*', *type 'QSysInfo::WinVersion'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * 'QSysInfo::*', *type 'QSysInfo::MacVersion'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: Enum constant 'QSysInfo::BigEndian' belongs to unknown type QSysInfo"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: Enum constant 'QSysInfo::LittleEndian' belongs to unknown type QSysInfo"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping field 'QSysInfo::*' with unmatched type 'QSysInfo::MacVersion'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping field 'QSysInfo::*' with unmatched type 'QSysInfo::WinVersion'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: enum 'QSysInfo::*' does not have a type entry or is not an enum"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: unknown operator 'Code'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'Qt::operator|', unmatched return type 'QIncompatibleFlag'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'Qt::operator|', unmatched return type 'QFlags<*::enum_type>'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function '*', unmatched *type 'unsigned'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QCborMap::*', unmatched parameter type 'const char[N]'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: Something has happened when trying to read array initialization: N"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: namespace 'java.util.Collection' for enum 'AllocationOption' is not declared"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: unhandled enum value: sizeof(qreal)==sizeof(double)?Double:Float in QMetaType::Type"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: possible compilation error in enum value sizeof(qreal)==sizeof(double)?Double:Float"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: Cannot find enum constant for value 'QCborTag(-1)' in 'QCborValue' or any of its super classes"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: signature 'operator=(QFuture)' for function modification in 'QFuture' not found. Possible candidates:"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping field 'QStaticPlugin::*' with unmatched type '*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: enum 'ConvertResponse' does not have a type entry or is not an enum"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: enum 'jValueType' does not have a type entry or is not an enum"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: signature 'readStringChunk(char*,qsizetype)' for function modification in 'QCborStreamReader' not found. Possible candidates:*"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: namespace 'QMetaObject' for enum 'Call' is not declared"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: namespace 'io.qt.core.QMetaObject' for enum 'Call' is not declared"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: Class 'QCborValue' has equals operators but no qHash() function. Hashcode of objects will consistently be 0."}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: Class 'QFuture' has equals operators but no qHash() function. Hashcode of objects will consistently be 0."}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: namespace 'io.qt.core.QVariant' for enum 'Type' is not declared"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QTransform::asAffineMatrix', unmatched return type 'auto'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QDataStream::operator*', unmatched parameter type '*char32_t*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QDataStream::operator*', unmatched parameter type '*char16_t*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QStaticPlugin::QStaticPlugin', unmatched parameter type 'QtPluginInstanceFunction'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QByteArray::QByteArray', unmatched parameter type '*QByteArray::DataPointer*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QMetaMethod::QMetaMethod', unmatched parameter type '*QMetaMethod::Data*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function '*', unmatched parameter type 'QGenericArgument'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function '*', unmatched parameter type 'QGenericReturnArgument'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type '*QStringConverter::Interface*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type '*QFutureInterfaceBase*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function '*::static_assert'*"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping field 'QStringConverterBase$State::clearFn' with unmatched type '*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: enum 'QtJambiNativeID' does not have a type entry or is not an enum"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: template baseclass 'QListSpecialMethods<T>' of 'QList' is not known"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: Something has happened when trying to read array initialization: Size"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QByteArrayView::QByteArrayView*', unmatched parameter type 'const char[Size]'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: signature 'QIODeviceBase()' for function modification in 'QIODeviceBase' not found. Possible candidates:"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function '*', unmatched parameter type 'QEvent::*EventTag'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function '*QtPrivate::*', *"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: enum 'QtPrivate::Deprecated_t' does not have a type entry or is not an enum"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QKeyCombination::QKeyCombination', unmatched parameter type 'Qt::Modifiers'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function '*', unmatched *type '*QException*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: enum 'QtPrivate::Ordering' does not have a type entry or is not an enum"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: enum 'QtPrivate::Uncomparable' does not have a type entry or is not an enum"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: Operator type unknown: QList::const_iterator::operator const T*()const"}
    SuppressedWarning{text: "WARNING(CppImplGenerator) :: class '*' inherits from interface 'QIODeviceBase', but has no polymorphic id set"}
    SuppressedWarning{text: "WARNING(CppImplGenerator) :: enum not found: 'QVariant::Type'"}
    SuppressedWarning{text: "WARNING(JavaGenerator) :: No ==/!= operator found for value type QCollatorSortKey."}
    SuppressedWarning{text: "WARNING(JavaGenerator) :: No ==/!= operator found for value type QCommandLineOption."}
    SuppressedWarning{text: "WARNING(JavaGenerator) :: No ==/!= operator found for value type QJsonParseError."}
    SuppressedWarning{text: "WARNING(JavaGenerator) :: No ==/!= operator found for value type QTimeZone::OffsetData."}
    SuppressedWarning{text: "WARNING(JavaGenerator) :: No ==/!= operator found for value type QStringMatcher."}
    SuppressedWarning{text: "WARNING(JavaGenerator) :: No ==/!= operator found for value type QStaticPlugin."}
    SuppressedWarning{text: "WARNING(JavaGenerator) :: No ==/!= operator found for value type QRegularExpressionMatch."}
    SuppressedWarning{text: "WARNING(JavaGenerator) :: No ==/!= operator found for value type QRegularExpressionMatchIterator."}
    SuppressedWarning{text: "WARNING(JavaGenerator) :: No ==/!= operator found for value type QPropertyBindingError."}
    SuppressedWarning{text: "WARNING(JavaGenerator) :: No ==/!= operator found for value type QUntypedBindable."}
    SuppressedWarning{text: "WARNING(JavaGenerator) :: No ==/!= operator found for value type QUntypedPropertyBinding."}
    SuppressedWarning{
        text: "WARNING(CppImplGenerator) :: Value type 'QItemSelection' is missing a default constructor. The resulting C++ code will not compile.*"
        since: 6
    }
    SuppressedWarning{text: "WARNING(CppImplGenerator) :: Unknown class 'QVariant' for enum 'QVariant::Type'"}
    SuppressedWarning{text: "WARNING(CppImplGenerator) :: Unknown class 'QMetaObject' for enum 'QMetaObject::Call'"}
    SuppressedWarning{text: "WARNING(CppImplGenerator) :: enum not found: 'QMetaObject::Call'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: Type parser doesn't recognize the type const char (&)[Size] (is_busted)"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: Type parser doesn't recognize the type std::function<void()> (is_busted)"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: Type parser doesn't recognize the type std::function<void ()> (is_busted)"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type '*BindingFunctionVTable*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function '*', unmatched *type '*std::chrono*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function '*', unmatched *type '*QPropertyChangeHandler*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function '*', unmatched *type '*QPropertyNotifier*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function '*', unmatched *type '*QPropertyObserverBase::ChangeHandler*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: function 'QtMessageHandler' is specified in typesystem, but not declared"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QRandomGenerator::QRandomGenerator*', unmatched parameter type 'const quint32[N]'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: Type parser doesn't recognize the type const quint32 (&)[N] (is_busted)"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QRandomGenerator::_fillRange', unmatched parameter type 'qptrdiff'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QtFuture::makeReadyFuture*'*"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: signature 'reportFinished(const JObjectWrapper*)' for function modification in 'QtJambiFutureInterface' not found.*"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QFuture::*', unmatched parameter type '*QFuture*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QCalendar::QCalendar', unmatched parameter type 'QCalendar::SystemId'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QMetaProperty::getMetaPropertyData', unmatched return type 'QMetaProperty::Data'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: signature 'QPropertyObserverBase()' for function modification in 'QPropertyObserverBase' not found. Possible candidates:"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: Operator type unknown: QFuture::operator T()const"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: Shadowing: QOperatingSystemVersionBase::isAnyOfType(std::initializer_list* types) const and QOperatingSystemVersion::isAnyOfType(std::initializer_list* types) const; Java code will not compile"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping field 'QtPrivate::Deprecated' with unmatched type 'QtPrivate::Deprecated_t'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: Shadowing: QOperatingSystemVersionBase::* and QOperatingSystemVersion::* Java code will not compile"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: signature '*qfloat16*' for function modification in '*' not found.*"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping *, unmatched *type '*std::exception_ptr*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: Type parser doesn't recognize the type std::function<bool(const void*,void*)> (is_busted)"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: Type parser doesn't recognize the type std::function<bool(void*,void*)> (is_busted)"}
    SuppressedWarning{
        text: "WARNING(MetaJavaBuilder) :: signature 'QStringConverterBase()' for function modification in 'QStringConverterBase' not found. Possible candidates:"
        since: [6, 4]
    }
    SuppressedWarning{
        text: "WARNING(MetaJavaBuilder) :: skipping function 'QVersionNumber::QVersionNumber*', unmatched parameter type '*QVarLengthArray*'"
        since: [6, 4]
    }
    SuppressedWarning{
        text: "WARNING(Parser) :: scope not found for function definition: 'QLatin1StringView::*' - definition *ignored*"
        since: [6, 4]
    }
    SuppressedWarning{
        text: "WARNING(Parser) :: scope not found for symbol: q23::invoke_r*"
        since: [6, 4]
    }
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: signature '*char32_t*' for *modification in '*' not found. Possible candidates:"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: enum 'QString::NormalizationForm' does not have a type entry or is not an enum"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function 'QString::QString', unmatched parameter type 'QString::DataPointer*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function '*', unmatched *type 'QCharRef'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function '*', unmatched *type 'va_list'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type '*QString::Null*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping * unmatched *type '*Qt::Disambiguated_t*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function '*', unmatched *type 'QStringDataPtr'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function '*', unmatched *type 'QChar::SpecialCharacter'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function '*', unmatched *type 'QString::SplitBehavior'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: enum 'QString::SplitBehavior' does not have a type entry or is not an enum"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: Type parser doesn't recognize the type To (From::*)() (is_busted)"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: missing instantiations for template method QPromise*"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: missing instantiations for template method QFuture*"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: template baseclass 'QUrlTwoFlags<QUrl::UrlFormattingOption,QUrl::ComponentFormattingOption>' of 'QUrl$FormattingOptions' is not known"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping function '*', unmatched parameter type '*std::variant*'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: Class 'QVariant' has equals operators but no qHash() function. Hashcode of objects will consistently be 0."}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: signature 'QPartialOrdering()' for function modification in 'QPartialOrdering' not found. Possible candidates:"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: signature 'qHash(QPartialOrdering)' for function modification in 'QPartialOrdering' not found. Possible candidates:"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: skipping field 'QSequentialConstIterator::i' with unmatched type 'Node'"}
    SuppressedWarning{text: "WARNING(MetaJavaBuilder) :: class 'QSequentialConstIterator' inherits from unknown base class 'QByteArrayView::pointer'"}
}
