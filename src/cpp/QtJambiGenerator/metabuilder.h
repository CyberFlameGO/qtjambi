/****************************************************************************
**
** Copyright (C) 1992-2009 Nokia. All rights reserved.
** Copyright (C) 2009-2023 Dr. Peter Droste, Omix Visualization GmbH & Co. KG. All rights reserved.
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

#ifndef METABUILDER_H
#define METABUILDER_H

#include "codemodel.h"
#include "metalang.h"
#include "typesystem/utils.h"
#include "typeparser.h"

#include <QtCore/QSet>
#include "typesystem/typedatabase.h"
#include "docindex/docindexreader.h"

struct Operator;

class MetaBuilder {
    public:
        enum RejectReason {
            NotInTypeSystem,
            GenerationDisabled,
            RedefinedToNotClass,
            UnmatchedArgumentType,
            UnmatchedReturnType,
            IsPrivate,
            IsGlobal,
            NoReason
        };

        MetaBuilder(TS::TypeDatabase* database);
        virtual ~MetaBuilder();

        const MetaClassList& classes() const { return m_meta_classes; }
        const MetaFunctionalList& functionals() const { return m_meta_functionals; }
        MetaClassList classesTopologicalSorted() const;

        ScopeModelItem popScope() { return m_scopes.takeLast(); }
        void pushScope(ScopeModelItem item) { m_scopes << item; }
        ScopeModelItem currentScope() const { return m_scopes.last(); }

        void dumpLog();

        bool build(FileModelItem&& dom);

        void applyDocs(const DocModel* model);

        void figureOutEnumValuesForClass(MetaClass *meta_class, QSet<MetaClass *> *classes, QSet<MetaClass *> *repeatClasses, QSet<QString> *warnings = nullptr);
        QVariant figureOutEnumValue(const uint size, const QString &name, QVariant value, MetaClass *global, MetaEnum *meta_enum, MetaFunction *meta_function = nullptr, QSet<QString> *warnings = nullptr);
        void figureOutEnumValues();
        void figureOutDefaultEnumArguments();
        void figureOutFunctionsInNamespace(const NamespaceModelItem &item);

        void addAbstractMetaClass(MetaClass *cls);
        void addAbstractMetaFunctional(MetaFunctional *cls);
        MetaClass *traverseTypeAlias(TypeAliasModelItem item);
        MetaFunctional *traverseFunctional(TypeAliasModelItem item);
        MetaClass *traverseClass(ClassModelItem item);
        bool setupInheritance(MetaClass *meta_class);
        bool setupTemplateInstantiations(MetaClass *meta_class);
        MetaClass *traverseNamespace(NamespaceModelItem item);
        MetaEnum *traverseEnum(EnumModelItem item, MetaClass *enclosing, const QSet<QString> &metaEnums, const QMap<QString,QString>& flagByEnums);
        MetaClass * instantiateIterator(IteratorTypeEntry *iteratorTypeEntry, MetaClass *subclass, const QList<const MetaType *>& template_types, const QHash<const TypeEntry *,const MetaType *>& template_types_by_name);
        void traverseEnums(ScopeModelItem item, MetaClass *parent, const QSet<QString> &metaEnums, const QMap<QString,QString>& flagByEnums);
        void traverseFunctions(ScopeModelItem item, MetaClass *parent);
        void traverseFields(ScopeModelItem item, MetaClass *parent);
        void traverseStreamOperator(FunctionModelItem function_item);
        void traverseCompareOperator(FunctionModelItem item);
        MetaFunction *traverseFunction(FunctionModelItem function);
        MetaField *traverseField(VariableModelItem field, const MetaClass *cls);
        void checkFunctionModifications();
        void registerHashFunction(FunctionModelItem function_item);
        void registerToStringCapability(FunctionModelItem function_item);

        void parseQ_Property(MetaClass *meta_class, const QStringList &declarations);
        void setupEquals(MetaClass *meta_class);
        void setupBeginEnd(MetaClass *meta_class);
        void setupComparable(MetaClass *meta_class);
        void setupClonable(MetaClass *cls);
        void setupFunctionDefaults(MetaFunction *meta_function, MetaClass *meta_class);

        QString translateDefaultValue(const QString& defaultValueExpression, MetaType *type,
                                      MetaFunction *fnc, MetaClass *,
                                      int argument_index);
        MetaType *translateType(const TypeInfo& type_info, bool* ok, const QString &contextString = QString(),
                                      bool resolveType = true, bool resolveScope = true, bool prependScope = true);

        static void decideUsagePattern(MetaType *type);

        bool inheritHiddenBaseType(MetaClass *subclass,
                             const MetaClass *template_class,
                             const TypeParser::Info &info);
        MetaType *inheritTemplateType(const QList<const MetaType *> &template_types, const MetaType *meta_type, bool *ok = nullptr);

        bool isClass(const QString &qualified_name, const QString& className);
        bool isEnum(const QStringList &qualified_name);

        void fixQObjectForScope(NamespaceModelItem item);

        const QString& outputDirectory() const { return m_out_dir; }
        void setOutputDirectory(const QString &outDir) { m_out_dir = outDir; }
        void setFeatures(const QMap<QString, QString>& features){ m_features = &features; }
        void setQtVersion(uint qtVersionMajor, uint qtVersionMinor, uint qtVersionPatch, uint qtjambiVersionPatch) {
            m_qtVersionMajor = qtVersionMajor;
            m_qtVersionMinor = qtVersionMinor;
            m_qtVersionPatch = qtVersionPatch;
            m_qtjambiVersionPatch = qtjambiVersionPatch;
        }
        const QMap<QString,TypeSystemTypeEntry *>& typeSystemByPackage() const { return m_typeSystemByPackage; }
        const QMap<TypeSystemTypeEntry *,QSet<QString>>& containerBaseClasses() const { return m_containerBaseClasses; }
        const QStringList &getIncludePathsList() const;
        void setIncludePathsList(const QStringList &newIncludePathsList);

        const QString &generateTypeSystemQML() const;
        void setGenerateTypeSystemQML(const QString &newGenerateTypeSystemQML);

protected:
        MetaType* exchangeTemplateTypes(const MetaType* type, bool isReturn, const QMap<QString,MetaType*>& templateTypes);
        MetaClass *argumentToClass(ArgumentModelItem, const QString &contextString);

    private:
        TypeInfo analyzeTypeInfo(MetaClass *cls, QString strg);
        MetaFunctional * findFunctional(MetaClass *cls, const FunctionalTypeEntry * fentry);
        void fixMissingIterator();
        void sortLists();
        Operator findOperator(const uint size, QString *s,
                              MetaClass *global,
                              MetaEnum *meta_enum,
                              MetaFunction *meta_function, QSet<QString> *warnings = nullptr);

        struct RenamedOperator{
            QString newName;
            TypeEntry *castType;
            bool skip;
        };

        RenamedOperator rename_operator(const QString &oper);

        QString m_out_dir;

        MetaClassList m_meta_classes;
        MetaFunctionalList m_meta_functionals;
        MetaClassList m_templates;
        MetaClassList m_template_iterators;
        FileModelItem m_dom;

        QSet<const TypeEntry *> m_used_types;

        QMap<QPair<QString,QString>, RejectReason> m_rejected_classes;
        QMap<QPair<QString,QString>, RejectReason> m_rejected_functionals;
        QMap<QPair<QString,QString>, RejectReason> m_rejected_enums;
        QMap<QPair<QString,QString>, RejectReason> m_rejected_functions;
        QMap<QPair<QString,QString>, RejectReason> m_rejected_template_functions;
        QMap<QPair<QString,QString>, RejectReason> m_rejected_signals;
        QMap<QPair<QString,QString>, RejectReason> m_rejected_fields;

        QList<MetaEnum *> m_enums;

        QMap<QString, MetaEnumValue *> m_enum_values;

        MetaClass *m_current_class;
        MetaFunction *m_current_function;
        QList<ScopeModelItem> m_scopes;
        QString m_namespace_prefix;

        QSet<MetaClass *> m_setup_inheritance_done;

        struct MissingIterator{
            MissingIterator(const IteratorTypeEntry* _iteratorType,
                            MetaType *_meta_type,
            MetaClass * _current_class) :
                iteratorType(_iteratorType),
                meta_type(_meta_type),
                current_class(_current_class)
            {}
            const IteratorTypeEntry* iteratorType;
            MetaType *meta_type;
            MetaClass * current_class;
        };
        QList<MissingIterator> m_missing_iterators;
        const QMap<QString, QString>* m_features;
        QMap<QString,TypeSystemTypeEntry *> m_typeSystemByPackage;
        QMap<TypeSystemTypeEntry *,QSet<QString>> m_containerBaseClasses;
        QList<MetaEnum *> m_scopeChangedEnums;
        QStringList m_includePathsList;
        uint m_qtVersionMajor;
        uint m_qtVersionMinor;
        uint m_qtVersionPatch;
        uint m_qtjambiVersionPatch;
        TS::TypeDatabase* m_database;
        QString m_generateTypeSystemQML;
};

struct Operator {
    enum Type { Plus, Minus, ShiftLeft, Not, None };

    Operator(const uint _size) : type(None), size(_size), value() { }

    QVariant calculate(QVariant x);

    QString toString(QString x);

    Type type;
    const uint size;
    QVariant value;
};

#endif // ABSTRACTMETBUILDER_H
