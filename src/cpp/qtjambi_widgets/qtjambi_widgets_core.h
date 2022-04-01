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

#if defined __cplusplus
#ifndef QTJAMBI_WIDGETS_CORE_H
#define QTJAMBI_WIDGETS_CORE_H

#include <qtjambi/qtjambi_global.h>
#include <QtWidgets/QtWidgets>

inline hash_type qHash(const QScrollerProperties & value)
{
    class ScrollerProperties : public QScrollerProperties{
    public:
        inline hash_type hashCode() const{
            return qHash(qintptr(d.get()));
        }
    };

    return reinterpret_cast<const ScrollerProperties&>(value).hashCode();
}

inline hash_type qHash(const QTableWidgetSelectionRange& value)
{
    hash_type hashCode = qHash(value.topRow());
    hashCode = hashCode * 31 + qHash(value.leftColumn());
    hashCode = hashCode * 31 + qHash(value.bottomRow());
    hashCode = hashCode * 31 + qHash(value.rightColumn());
    return hashCode;
}

#endif // QTJAMBI_WIDGETS_CORE_H
#endif // defined __cplusplus
