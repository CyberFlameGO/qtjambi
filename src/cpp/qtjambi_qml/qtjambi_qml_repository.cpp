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

#include <QtCore/QMutex>
#include "qtjambi_qml_repository.h"

namespace Java{
namespace QtJambi {
QTJAMBI_REPOSITORY_DEFINE_CLASS(io/qt,QtMetaType,
                                 QTJAMBI_REPOSITORY_DEFINE_METHOD(type,()Lio/qt/core/QMetaType$Type;)
                                 QTJAMBI_REPOSITORY_DEFINE_METHOD(name,()Ljava/lang/String;)
                                 QTJAMBI_REPOSITORY_DEFINE_METHOD(id,()I))
}

namespace QtQml{
QTJAMBI_REPOSITORY_DEFINE_CLASS(io/qt/qml,QQmlExpression$ValueIsUndefined,
                                QTJAMBI_REPOSITORY_DEFINE_CONSTRUCTOR(Ljava/lang/String;)
)

QTJAMBI_REPOSITORY_DEFINE_CLASS(io/qt/qml,QQmlIncubationController$WhileFlag,
                                QTJAMBI_REPOSITORY_DEFINE_FIELD(flag,J)
)
QTJAMBI_REPOSITORY_DEFINE_CLASS(io/qt/qml,QQmlListProperty,)
QTJAMBI_REPOSITORY_DEFINE_CLASS(io/qt/qml,QQmlListProperty$ReplaceFunction,
                                QTJAMBI_REPOSITORY_DEFINE_METHOD(accept,(Ljava/lang/Object;JLjava/lang/Object;)V))
QTJAMBI_REPOSITORY_DEFINE_CLASS(io/qt/qml,QQmlListProperty$AtFunction,
                                QTJAMBI_REPOSITORY_DEFINE_METHOD(apply,(Ljava/lang/Object;J)Ljava/lang/Object;))
QTJAMBI_REPOSITORY_DEFINE_CLASS(io/qt/qml,QJSValue,)
QTJAMBI_REPOSITORY_DEFINE_CLASS(io/qt/qml/util,QmlTypeRegistrationException,
    QTJAMBI_REPOSITORY_DEFINE_CONSTRUCTOR(Ljava/lang/String;)
)
namespace Util{
    QTJAMBI_REPOSITORY_DEFINE_CLASS(io/qt/qml/util,QmlSingleton,)
    QTJAMBI_REPOSITORY_DEFINE_CLASS(io/qt/qml/util,QmlElement,)
    QTJAMBI_REPOSITORY_DEFINE_CLASS(io/qt/qml/util,QmlNamedElement,)
    QTJAMBI_REPOSITORY_DEFINE_CLASS(io/qt/qml/util,QmlValueType,)
    QTJAMBI_REPOSITORY_DEFINE_CLASS(io/qt/qml/util,QmlUncreatable,)
    QTJAMBI_REPOSITORY_DEFINE_CLASS(io/qt/qml/util,QmlUnavailable,)
    QTJAMBI_REPOSITORY_DEFINE_CLASS(io/qt/qml/util,QmlExtended,
                                    QTJAMBI_REPOSITORY_DEFINE_METHOD(value,()Ljava/lang/Class;))
    QTJAMBI_REPOSITORY_DEFINE_CLASS(io/qt/qml/util,QmlAnonymous,)
    QTJAMBI_REPOSITORY_DEFINE_CLASS(io/qt/qml/util,QmlInterface,)
    QTJAMBI_REPOSITORY_DEFINE_CLASS(io/qt/qml/util,QmlAttached,
                                    QTJAMBI_REPOSITORY_DEFINE_METHOD(value,()Ljava/lang/Class;))
    QTJAMBI_REPOSITORY_DEFINE_CLASS(io/qt/qml/util,QmlForeign,
                                    QTJAMBI_REPOSITORY_DEFINE_METHOD(value,()Ljava/lang/Class;)
                                    QTJAMBI_REPOSITORY_DEFINE_METHOD(metaType,()Lio/qt/QtMetaType;))
    QTJAMBI_REPOSITORY_DEFINE_CLASS(io/qt/qml/util,QmlSequencialContainer,
                                    QTJAMBI_REPOSITORY_DEFINE_METHOD(value,()Ljava/lang/Class;)
                                    QTJAMBI_REPOSITORY_DEFINE_METHOD(valueType,()Lio/qt/QtMetaType;))
}
}
}
