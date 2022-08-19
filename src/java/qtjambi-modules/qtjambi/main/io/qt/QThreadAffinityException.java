/****************************************************************************
**
** Copyright (C) 1992-2009 Nokia. All rights reserved.
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
package io.qt;

import io.qt.core.*;


/**
 * The QThreadAffinityException class is thrown when a QObject is used outside
 * its own thread.
 *
 * Each QObject has thread affinity, a thread that it belongs to, which is
 * accessible through its thread() method. Accessing an object from outside
 * this thread is forbidden to avoid concurrency problems.
 *
 * Qt Jambi checks if threading affinity is violated in each member of each QObject subclass. It is
 * possible to disable this check by setting the VM runtime parameter
 * <code>io.qt.thread-check</code> to <code>false</code>.
 *
 * @see io.qt.core.QObject#thread()
 */
public class QThreadAffinityException extends RuntimeException {


    /**
     * Creates a new QThreadAffinityException with the given message, object and thread.
     * @param message Describes the affinity exception.
     * @param object The object that was accessed.
     * @param expectedThread The expected thread.
     * @param currentThread The thread from which the access was made.
     */
	@NativeAccess
    public QThreadAffinityException(String message, QObject object, QThread expectedThread, QThread currentThread) {
        super(message);
        this.object = object;
        this.expectedThread = expectedThread;
        this.currentThread = currentThread;
    }
	
	@NativeAccess
    private QThreadAffinityException(String message) {
        super(message);
        this.object = null;
        this.expectedThread = null;
        this.currentThread = null;		
	}


    /**
     * Returns a string representation of this exception.
     * @return This exception as a string.
     */
    @Override
    public String toString() {
        StringBuilder s = new StringBuilder();
        s.append(getMessage());
        if(object!=null && expectedThread!=null && currentThread!=null) {
	        if(!getMessage().endsWith(".") && !getMessage().endsWith(",") && !getMessage().endsWith("!") && !getMessage().endsWith(":"))
	        	s.append(":");
	        if(object!=null) {
		        if(object.isDisposed()) {
		        	s.append(" object=").append(object.getClass().getName()).append("@").append(Integer.toHexString(System.identityHashCode(object)));
		        }else {
		        	s.append(" object=").append(object);
		        }
		        s.append(", ");
	        }
	        Thread expectedJavaThread = null;
	        try {
				expectedJavaThread = expectedThread.javaThread();
			} catch (Exception e1) {
			}
	        if(expectedJavaThread!=null) {
	        	s.append(" expectedThread=").append(expectedJavaThread);
	        }else if(object.isDisposed()) {
	        	s.append(" expectedThread=").append(expectedThread.getClass().getName()).append("@").append(Integer.toHexString(System.identityHashCode(expectedThread)));
	        }else {
	        	s.append(" expectedThread=").append(expectedThread);
	        }
	        Thread currentJavaThread = null;
	        try {
				currentJavaThread = currentThread.javaThread();
			} catch (Exception e) {
			}
	        if(currentJavaThread!=null) {
	        	s.append(", currentThread=").append(currentJavaThread);
	        }else if(currentThread.isDisposed()) {
	        	s.append(", currentThread=").append(currentThread.getClass().getName()).append("@").append(Integer.toHexString(System.identityHashCode(currentThread)));
	        }else {
	        	s.append(", currentThread=").append(currentThread);
	        }
        }
        return s.toString();
    }

    private final QObject object;
    private final QThread currentThread;
    private final QThread expectedThread;

    private static final long serialVersionUID = 1L;

	public QObject object() {
		return object;
	}


	public QThread currentThread() {
		return currentThread;
	}


	public QThread expectedThread() {
		return expectedThread;
	}
}
