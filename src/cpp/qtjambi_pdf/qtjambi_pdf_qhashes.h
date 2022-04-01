/****************************************************************************
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


#ifndef QTJAMBI_PDF_QHASHES_H
#define QTJAMBI_PDF_QHASHES_H

#include <qtjambi/qtjambi_global.h>
#include <qtjambi_gui/qtjambi_gui_qhashes.h>
#include <QtPdf/QPdfDocumentRenderOptions>
#include <QtPdf/QPdfSearchResult>
#include <QtPdf/QPdfSelection>

inline hash_type qHash(const QPdfDocumentRenderOptions& value)
{
    hash_type hashCode = qHash(value.scaledClipRect());
    hashCode = hashCode * 31 + qHash(value.scaledSize());
    hashCode = hashCode * 31 + qHash(value.renderFlags());
    hashCode = hashCode * 31 + qHash(value.rotation());
    return hashCode;
}

inline hash_type qHash(const QPdfSelection &value)
{
    hash_type hashCode = qHash(value.isValid());
    hashCode = hashCode * 31 + qHash(value.bounds());
    hashCode = hashCode * 31 + qHash(value.text());
    hashCode = hashCode * 31 + qHash(value.boundingRectangle());
    hashCode = hashCode * 31 + qHash(value.startIndex());
    hashCode = hashCode * 31 + qHash(value.endIndex());
    return hashCode;
}

inline hash_type qHash(const QPdfDestination &value)
{
    hash_type hashCode = qHash(value.isValid());
    hashCode = hashCode * 31 + qHash(value.page());
    hashCode = hashCode * 31 + qHash(value.location().x());
    hashCode = hashCode * 31 + qHash(value.location().y());
    hashCode = hashCode * 31 + qHash(value.zoom());
    return hashCode;
}

inline hash_type qHash(const QPdfSearchResult &value)
{
    hash_type hashCode = qHash(value.contextBefore());
    hashCode = hashCode * 31 + qHash(value.contextAfter());
    hashCode = hashCode * 31 + qHash(value.rectangles());
    hashCode = hashCode * 31 + qHash(static_cast<const QPdfDestination &>(value));
    return hashCode;
}

inline bool operator==(const QPdfSelection &value1, const QPdfSelection &value2)
{
    return value1.isValid()==value2.isValid()
            && value1.bounds()==value2.bounds()
            && value1.text()==value2.text()
            && value1.boundingRectangle()==value2.boundingRectangle()
            && value1.startIndex()==value2.startIndex()
            && value1.endIndex()==value2.endIndex();
}

inline bool operator==(const QPdfDestination &value1, const QPdfDestination &value2)
{
    return value1.isValid()==value2.isValid()
            && value1.page()==value2.page()
            && value1.location()==value2.location()
            && qFuzzyCompare(value1.zoom(), value2.zoom());
}

inline bool operator==(const QPdfSearchResult &value1, const QPdfSearchResult &value2)
{
    return value1.contextBefore()==value2.contextBefore()
            && value1.contextAfter()==value2.contextAfter()
            && value1.rectangles()==value2.rectangles()
            && static_cast<const QPdfDestination &>(value1)==static_cast<const QPdfDestination &>(value2);
}

#endif // QTJAMBI_PDF_QHASHES_H