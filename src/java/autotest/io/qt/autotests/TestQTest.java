/****************************************************************************
**
** Copyright (C) 1992-2009 Nokia. All rights reserved.
** Copyright (C) 2009-2021 Dr. Peter Droste, Omix Visualization GmbH & Co. KG. All rights reserved.
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
package io.qt.autotests;

import static org.junit.Assert.assertEquals;

import org.junit.Test;

import io.qt.core.QList;
import io.qt.test.QSignalSpy;
import io.qt.widgets.QCheckBox;

public class TestQTest extends QApplicationTest {
    @Test
    public void test() {
    	QCheckBox box = new QCheckBox();
    	QSignalSpy spy = new QSignalSpy(box.clicked);
    	assertEquals(0, spy.count());
    	box.click();
    	assertEquals(1, spy.count());
    	QList<Object> arguments = spy.takeFirst();
    	assertEquals(true, arguments.at(0));
    }
    
    public static void main(String args[]) {
        org.junit.runner.JUnitCore.main(TestQTest.class.getName());
    }
}
