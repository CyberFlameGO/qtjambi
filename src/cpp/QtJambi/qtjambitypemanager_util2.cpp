/****************************************************************************
**
** Copyright (C) 2009-2022 Dr. Peter Droste, Omix Visualization GmbH & Co. KG. All rights reserved.
**
** This file is part of Qt Jambi.
**
** ** $BEGIN_LICENSE$
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

#include "qtjambi_repository_p.h"
#include "qtjambi_jobjectwrapper.h"
#include "qtjambitypemanager_p.h"
#include "qtjambilink_p.h"
#include "qtjambi_core.h"
#include "qtjambi_cast.h"
#include "qtjambi_registry_p.h"
#include "qtjambi_interfaces.h"
#include "qtjambi_functionpointer.h"

#include <cstring>
#include <QThread>
#include <QtCore>

ExternalToInternalConverter ContainerConverter::getExternalToInternalConverter(const QString& container, const QString& internalTypeName, const ExternalToInternalConverter& memberConverter, bool isPointer, bool isStaticType, size_t align, size_t size, int memberMetaType)
{
    if(isPointer)
        size = 0;
    if(container=="QVector"){
#define ELEMENT_SIZE_CASEACTION(SZ)\
        return ContainerConverter::getExternalToInternalConverter<QVector,0,SZ,true>(internalTypeName, memberConverter, memberMetaType);
        ELEMENT_SIZE_SWITCH(size)
#undef ELEMENT_SIZE_CASEACTION
    }else if(container=="QStack"){
#define ELEMENT_SIZE_CASEACTION(SZ)\
        return ContainerConverter::getExternalToInternalConverter<QStack,0,SZ,true>(internalTypeName, memberConverter, memberMetaType);
        ELEMENT_SIZE_SWITCH(size)
#undef ELEMENT_SIZE_CASEACTION
    }else if(container=="QList"){
#define ELEMENT_STATICSIZE_CASEACTION(ST,SZ)\
        return ContainerConverter::getExternalToInternalConverter<QList,0,SZ,ST>(internalTypeName, memberConverter, memberMetaType);
        ELEMENT_STATICSIZE_SWITCH(isStaticType, size)
#undef ELEMENT_STATICSIZE_CASEACTION
    }else if(container=="QQueue"){
#define ELEMENT_STATICSIZE_CASEACTION(ST,SZ)\
        return ContainerConverter::getExternalToInternalConverter<QQueue,0,SZ,ST>(internalTypeName, memberConverter, memberMetaType);
        ELEMENT_STATICSIZE_SWITCH(isStaticType, size)
#undef ELEMENT_STATICSIZE_CASEACTION
    }else if(container=="QLinkedList"){
#define ELEMENT_SIZE_CASEACTION(SZ)\
        return ContainerConverter::getExternalToInternalConverter<QLinkedList,0,SZ,true>(internalTypeName, memberConverter, memberMetaType);
        ELEMENT_SIZE_SWITCH(size)
#undef ELEMENT_SIZE_CASEACTION
    }else if(container=="QSet"){
#define ELEMENT_ALIGNSIZE_CASEACTION(AL,SZ)\
        return ContainerConverter::getExternalToInternalConverter<QSet,AL,SZ,true>(internalTypeName, memberConverter, memberMetaType);
        ELEMENT_ALIGNSIZE_SWITCH(align,size)
#undef ELEMENT_ALIGNSIZE_CASEACTION
    }
    return nullptr;
}

ExternalToInternalConverter ContainerConverter::getExternalToInternalConverter_QPair(const QString& container, const QString& internalTypeName, const ExternalToInternalConverter& memberConverter1, bool isPointer1, bool isStaticType1, size_t align1, size_t size1, int memberMetaType1, const ExternalToInternalConverter& memberConverter2, bool isPointer2, bool isStaticType2, size_t align2, size_t size2, int memberMetaType2)
{
    Q_UNUSED(isStaticType1)
    Q_UNUSED(isStaticType2)
    if(isPointer1)
        size1 = 0;
    if(isPointer2)
        size2 = 0;
    if(container=="QPair"){
#define ELEMENT_ALIGNSIZE2_CASEACTION(AL1,SZ1,AL2,SZ2)\
        return ContainerConverter::getExternalToInternalConverter_QPair<QPair,AL1,SZ1,true,AL2,SZ2,true>(internalTypeName, memberConverter1, memberMetaType1, memberConverter2, memberMetaType2);
        ELEMENT_ALIGNSIZE2_SWITCH(align1,size1,align2,size2)
#undef ELEMENT_ALIGNSIZE2_CASEACTION
    }else if(container=="std::pair"){
#define ELEMENT_ALIGNSIZE2_CASEACTION(AL1,SZ1,AL2,SZ2)\
        return ContainerConverter::getExternalToInternalConverter_QPair<std::pair,AL1,SZ1,true,AL2,SZ2,true>(internalTypeName, memberConverter1, memberMetaType1, memberConverter2, memberMetaType2);
        ELEMENT_ALIGNSIZE2_SWITCH(align1,size1,align2,size2)
#undef ELEMENT_ALIGNSIZE2_CASEACTION
    }
    return nullptr;
}

ExternalToInternalConverter ContainerConverter::getExternalToInternalConverter(const QString& container, const QString& internalTypeName, const ExternalToInternalConverter& memberConverter1, bool isPointer1, bool isStaticType1, size_t align1, size_t size1, int memberMetaType1, const ExternalToInternalConverter& memberConverter2, bool isPointer2, bool isStaticType2, size_t align2, size_t size2, int memberMetaType2)
{
    Q_UNUSED(isStaticType1)
    Q_UNUSED(isStaticType2)
    if(isPointer1)
        size1 = 0;
    if(isPointer2)
        size2 = 0;
    if(container=="QMap"){
#define ELEMENT_ALIGNSIZE2_CASEACTION(AL1,SZ1,AL2,SZ2)\
        return ContainerConverter::getExternalToInternalConverter<QMap,AL1,SZ1,true,AL2,SZ2,true>(internalTypeName, memberConverter1, memberMetaType1, memberConverter2, memberMetaType2);
        ELEMENT_ALIGNSIZE2_SWITCH(align1,size1,align2,size2)
#undef ELEMENT_ALIGNSIZE2_CASEACTION
    }else if(container=="QMultiMap"){
#define ELEMENT_ALIGNSIZE2_CASEACTION(AL1,SZ1,AL2,SZ2)\
        return ContainerConverter::getExternalToInternalConverter<QMultiMap,AL1,SZ1,true,AL2,SZ2,true>(internalTypeName, memberConverter1, memberMetaType1, memberConverter2, memberMetaType2);
        ELEMENT_ALIGNSIZE2_SWITCH(align1,size1,align2,size2)
#undef ELEMENT_ALIGNSIZE2_CASEACTION
    }else if(container=="QHash"){
#define ELEMENT_ALIGNSIZE2_CASEACTION(AL1,SZ1,AL2,SZ2)\
        return ContainerConverter::getExternalToInternalConverter<QHash,AL1,SZ1,true,AL2,SZ2,true>(internalTypeName, memberConverter1, memberMetaType1, memberConverter2, memberMetaType2);
        ELEMENT_ALIGNSIZE2_SWITCH(align1,size1,align2,size2)
#undef ELEMENT_ALIGNSIZE2_CASEACTION
    }else if(container=="QMultiHash"){
#define ELEMENT_ALIGNSIZE2_CASEACTION(AL1,SZ1,AL2,SZ2)\
        return ContainerConverter::getExternalToInternalConverter<QMultiHash,AL1,SZ1,true,AL2,SZ2,true>(internalTypeName, memberConverter1, memberMetaType1, memberConverter2, memberMetaType2);
        ELEMENT_ALIGNSIZE2_SWITCH(align1,size1,align2,size2)
#undef ELEMENT_ALIGNSIZE2_CASEACTION
    }
    return nullptr;
}
