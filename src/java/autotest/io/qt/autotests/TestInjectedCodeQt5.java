/****************************************************************************
**
** Copyright (C) 1992-2009 Nokia. All rights reserved.
**
** This file is part of Qt Jambi.
**
** ** $BEGIN_LICENSE$
** Commercial Usage
** Licensees holding valid Qt Commercial licenses may use this file in
** accordance with the Qt Commercial License Agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and Nokia.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
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
** If you are unsure which license is appropriate for your use, please
** contact the sales department at qt-sales@nokia.com.
** $END_LICENSE$

**
** This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
** WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
**
****************************************************************************/

package io.qt.autotests;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import org.junit.Test;

import io.qt.internal.*;
import io.qt.autotests.generated.*;
import io.qt.core.*;
import io.qt.gui.*;
import io.qt.widgets.*;

public class TestInjectedCodeQt5 extends QApplicationTest {
    
    @Test
    public void testQLineFintersection() {
        QLineF line1 = new QLineF(10, 0, 10, 20);
        QLineF line2 = new QLineF(0, 10, 20, 10);

        QPointF intersectionPoint = new QPointF();

        assertEquals(QLineF.IntersectType.BoundedIntersection, line1.intersects(line2, intersectionPoint));
        assertEquals(10.0, intersectionPoint.x(), 0.0);
        assertEquals(10.0, intersectionPoint.y(), 0.0);

        line2 = new QLineF(0, 30, 20, 30);
        assertEquals(QLineF.IntersectType.UnboundedIntersection, line1.intersects(line2, intersectionPoint));
        assertEquals(10.0, intersectionPoint.x(), 0.0);
        assertEquals(30.0, intersectionPoint.y(), 0.0);

        line2 = new QLineF(11, 0, 11, 20);
        assertEquals(QLineF.IntersectType.NoIntersection, line1.intersects(line2, null));
    }
    
    static class TextCodecSubclassSubclass extends TextCodecSubclass {
        char receivedChar[];
        byte receivedByte[];
        QTextCodec.ConverterState receivedState;

        @Override
        protected QByteArray convertFromUnicode(char[] data, QTextCodec.ConverterState state) {
            receivedChar = data;
            receivedState = state;
            return super.convertFromUnicode(data, state);
        }

        @Override
        protected String convertToUnicode(byte[] data, QTextCodec.ConverterState state) {
            receivedByte = data;
            receivedState = state;
            return super.convertToUnicode(data, state);
        }

        @Override
        public int mibEnum() {
            return 0;
        }

        @Override
        public QByteArray name() {
            return null;
        }
    }

    @Test
    public void testQPictureConstructor() {
        QPictureIO pictureIO = new QPictureIO(new QTemporaryFile(), "JPEG");
        assertEquals("JPEG", pictureIO.format());
        assertEquals("", pictureIO.fileName());

        pictureIO = new QPictureIO("someFile", "PNG");
        assertEquals("PNG", pictureIO.format());
        assertEquals("someFile", pictureIO.fileName());
    }

    @Test
    public void testQPictureParameters() {
        QPictureIO pictureIO = new QPictureIO("someFile", "PNG");

        pictureIO.setParameters("my parameters");
        assertEquals("my parameters", pictureIO.parameters());
    }
    

    @Test
    public void testTextCodecConvertToUnicode() {
        TextCodecSubclassSubclass tcss = new TextCodecSubclassSubclass();
        assertEquals(QtJambiInternal.Ownership.Cpp, QtJambiInternal.ownership(tcss));

        QTextCodec.ConverterState state = new QTextCodec.ConverterState();

        assertEquals("abba", tcss.callToUnicode(new QByteArray("baab"), state));
        assertTrue(state == tcss.receivedState);
        assertTrue(state == tcss.receivedState());
        assertEquals("baab", new QByteArray(tcss.receivedByte).toString());
        tcss.receivedState = null;
        tcss.dispose();
    }

    @Test
    public void testTextCodecConvertFromUnicode() {
        TextCodecSubclassSubclass tcss = new TextCodecSubclassSubclass();
        assertEquals(QtJambiInternal.Ownership.Cpp, QtJambiInternal.ownership(tcss));
        QTextCodec.ConverterState state = new QTextCodec.ConverterState();

        assertEquals("sas", tcss.callFromUnicode("asa", state).toString());
        assertTrue(state == tcss.receivedState);
        assertTrue(state == tcss.receivedState());
        assertEquals("asa", new String(tcss.receivedChar));
        tcss.receivedState = null;
        tcss.dispose();
    }

    @Test
    public void testQTextCodecForNameString() {
        QTextCodec codec = QTextCodec.codecForName("UTF-8");

        assertTrue(codec != null);
        assertEquals("UTF-8", codec.name().toString());

        codec = QTextCodec.codecForName("Magic Text Codec Which Successfully Improves What You've Written");
        assertTrue(codec == null);
    }
    
    public static void main(String args[]) {
        org.junit.runner.JUnitCore.main(TestInjectedCodeQt5.class.getName());
    }
}
