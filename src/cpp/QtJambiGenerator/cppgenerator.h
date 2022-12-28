/****************************************************************************
**
** Copyright (C) 1992-2009 Nokia. All rights reserved.
** Copyright (C) 2009-2022 Dr. Peter Droste, Omix Visualization GmbH & Co. KG. All rights reserved.
**
** This file is part of QtJambi.
**
** $BEGIN_LICENSE$
**
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

#ifndef CPPGENERATOR_H
#define CPPGENERATOR_H

#include "abstractgenerator.h"
#include "metalang.h"
#include "prigenerator.h"
#include "typedatabase.h"

class CppGenerator : public AbstractGenerator {
public:
    CppGenerator(PriGenerator *_priGenerator);
    QString resolveOutputDirectory() const override { return cppOutputDirectory(); }

    QString cppOutputDirectory() const {
        if (!m_cpp_out_dir.isNull())
            return m_cpp_out_dir;
        return outputDirectory() + QLatin1String("/cpp");
    }
    void setCppOutputDirectory(const QString &cppOutDir) { m_cpp_out_dir = cppOutDir; }

    QString subDirectoryForPackage(const QString &package) const;
    virtual QString subDirectoryForFunctional(const MetaFunctional * cls) const override
    { return subDirectoryForPackage(cls->targetTypeSystem()); }

    virtual QString subDirectoryForClass(const MetaClass *cls) const override {
        return subDirectoryForPackage(cls->targetTypeSystem());
    }

    static QString fixNormalizedSignatureForQt(const QString &signature);
    static void writeTypeInfo(QTextStream &s, const MetaType *type, Option option = NoOption);
    void writeFunctionSignature(QTextStream &s, const MetaFunction *java_function,
                                       const MetaClass *implementor = nullptr,
                                       const QString &name_prefix = QString(),
                                       Option option = NoOption,
                                       const QString &classname_prefix = QString(),
                                       const QStringList &extra_arguments = QStringList(),
                                       int numArguments = -1) const;
    void writeFunctionArguments(QTextStream &s, const MetaArgumentList &arguments,
                                       const MetaFunction *java_function,
                                       Option option = NoOption,
                                       int numArguments = -1) const;

    bool shouldGenerate(const MetaClass *java_class) const override {
        return (!java_class->isNamespace() || java_class->functionsInTargetLang().size() > 0)
               && !java_class->isInterface()
               && !java_class->typeEntry()->isVariant()
               && !java_class->typeEntry()->isIterator()
               && (java_class->typeEntry()->codeGeneration() & TypeEntry::GenerateCpp)
               && !java_class->isFake();
    }

    bool shouldGenerate(const MetaFunctional *functional) const override {
        if(functional->enclosingClass()){
            if(!(!functional->enclosingClass()->isFake()
                 && functional->enclosingClass()->typeEntry()
                 && (functional->enclosingClass()->typeEntry()->codeGeneration() & TypeEntry::GenerateCpp))){
                return false;
            }
        }
        return functional->typeEntry()->getUsing().isEmpty() && (functional->typeEntry()->codeGeneration() & TypeEntry::GenerateCpp);
    }

    static QString shellClassName(const MetaClass *java_class) {
        if(java_class->typeEntry()->designatedInterface() && java_class->enclosingClass()){
            return java_class->generateShellClass()
                   ? java_class->enclosingClass()->name() + "_shell"
                   : java_class->enclosingClass()->qualifiedCppName();
        }
        return java_class->generateShellClass()
               ? java_class->name() + "_shell"
               : java_class->qualifiedCppName();
    }

    static QString shellClassName(const MetaFunctional *java_class) {
        QString _shellClassName;
        if(java_class->enclosingClass() && !java_class->enclosingClass()->isFake()){
            _shellClassName = shellClassName(java_class->enclosingClass());
            if(_shellClassName.endsWith("_shell")){
                _shellClassName = _shellClassName.chopped(6);
            }
            _shellClassName += "$";
        }
        return _shellClassName + java_class->name() + "_shell";
        //return java_class->enclosingClass()
        //        ? shellClassName(java_class->enclosingClass()) + "$" + java_class->name()
        //                                    : java_class->name() + "_shell";
    }

    static QStringList getFunctionPPConditions(const MetaFunction *java_function);

    static QString translateType(const MetaType *java_type, Option option = NoOption);

    static QString marshalledArguments(const MetaFunction *java_function);

    enum JNISignatureFormat {
        Underscores = 0x0001,        //!< Used in the jni exported function names
        SlashesAndStuff = 0x0010,     //!< Used for looking up functions through jni
        ReturnType = 0x0100,
        NoQContainers = 0x0200,
        NoModification = 0x1000
    };

    static QString jni_signature(const QString &_full_name, JNISignatureFormat format);
    static QString jni_signature(const MetaFunction *function, JNISignatureFormat format);
    static QString jni_signature(const MetaFunctional *function, JNISignatureFormat format);
    static QString jni_signature(const MetaType *java_type, JNISignatureFormat format);
    static QString fixCppTypeName(const QString &name);
    inline TS::TypeDatabase* database() const {return priGenerator->database();}
protected:
    QByteArray jniName(const QString &name) const;
    PriGenerator *priGenerator;
    QString m_cpp_out_dir;
};


#endif // CPPGENERATOR_H
