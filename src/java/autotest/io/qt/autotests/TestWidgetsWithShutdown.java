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

import org.junit.Assert;
import org.junit.Test;

import io.qt.QThreadAffinityException;
import io.qt.core.QCoreApplication;
import io.qt.core.QThread;
import io.qt.core.QTimer;
import io.qt.core.Qt;
import io.qt.widgets.QApplication;
import io.qt.widgets.QCheckBox;
import io.qt.widgets.QHBoxLayout;
import io.qt.widgets.QSlider;
import io.qt.widgets.QSpinBox;
import io.qt.widgets.QWidget;

public class TestWidgetsWithShutdown {
	
    @Test
    public void test() {
    	System.setProperty("io.qt.log.messages", "ALL");
	    io.qt.QtResources.addSearchPath(".");
	    QCoreApplication.setApplicationName("QtJambiUnitTest");
	    QApplication.initialize(new String[]{"arg1", "arg2", "arg3"});
	    {
		    QWidget window = new QWidget();
			window.setWindowTitle( "Enter your age" );
			QCheckBox checkbox = new QCheckBox("Check &Box");
			QSpinBox spinbox = new QSpinBox();
			spinbox.setRange( 0, 130 );
			spinbox.setValue( 35 );
			QSlider slider = new QSlider( Qt.Orientation.Horizontal );
			slider.setRange( 0, 130 );
			slider.setValue( 35 );
			QHBoxLayout layout = new QHBoxLayout();
			layout.addWidget( spinbox );
			layout.addWidget( slider );
			layout.addWidget(checkbox);
			window.setLayout( layout );
			window.show();
			Throwable exception[] = {null};
			QThread thread = QThread.create(()->{
				try {
	    			QCoreApplication.shutdown();
	    		}catch(Throwable t) {
	    			exception[0] = t;
    			}
			});
			thread.start();
			thread.join();
		    Assert.assertTrue(exception[0] instanceof QThreadAffinityException);
			exception[0] = null;
	    	QTimer.singleShot(500, ()->{
	    		try {
	    			QCoreApplication.shutdown();
	    		}catch(Throwable t) {
	    			exception[0] = t;
    			}
	    		window.close();
    		});
	    	QCoreApplication.exec();
		    Assert.assertTrue(exception[0] instanceof IllegalStateException);
	    }
    	QCoreApplication.shutdown();
    }
}