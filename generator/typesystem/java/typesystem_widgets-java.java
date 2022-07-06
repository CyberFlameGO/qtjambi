    /****************************************************************************
**
** Copyright (C) 1992-2009 Nokia. All rights reserved.
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

package generator;

import io.qt.*;
import io.qt.QtUtilities;
import io.qt.internal.QtJambiObject.QPrivateConstructor;
import io.qt.core.QCoreApplication;
import io.qt.core.QPoint;
import io.qt.core.QPointF;
import io.qt.gui.*;

class QMenu___ extends QMenu {
        public native void setAsOSXDockMenu();
}// class

class QShortcut__{
    public QShortcut(io.qt.gui.QKeySequence key, io.qt.widgets.QWidget parent){
        this(key, parent, io.qt.core.Qt.ShortcutContext.WindowShortcut);
    }
    
    public QShortcut(io.qt.gui.QKeySequence key, io.qt.widgets.QWidget parent, io.qt.core.Qt.ShortcutContext context){
        this(key, parent, (java.lang.Object)null, (java.lang.Object)null, context);
    }
    
    public QShortcut(io.qt.gui.QKeySequence key, io.qt.widgets.QWidget parent, java.lang.String member, io.qt.core.Qt.ShortcutContext context){
        this(key, parent, member, (java.lang.String)null, context);
    }
    
    public QShortcut(io.qt.gui.QKeySequence key, io.qt.widgets.QWidget parent, java.lang.String member, java.lang.String ambiguousMember){
        this(key, parent, member, ambiguousMember, io.qt.core.Qt.ShortcutContext.WindowShortcut);
    }
    
    public QShortcut(io.qt.gui.QKeySequence key, io.qt.widgets.QWidget parent, java.lang.String member){
        this(key, parent, member, (java.lang.String)null, io.qt.core.Qt.ShortcutContext.WindowShortcut);
    }
    
    public QShortcut(io.qt.gui.QKeySequence key, io.qt.widgets.QWidget parent, java.lang.String member, java.lang.String ambiguousMember, io.qt.core.Qt.ShortcutContext context){
        this(key, parent, context);
        if(member!=null && !member.isEmpty())
            activated.connect(parent, member);
        if(ambiguousMember!=null && !ambiguousMember.isEmpty())
            activatedAmbiguously.connect(parent, ambiguousMember);
    }
    
    private static io.qt.widgets.QWidget parent(io.qt.core.QMetaObject.Slot0 slot){
        io.qt.core.QObject parent = QtJambi_LibraryUtilities.internal.lambdaContext(io.qt.core.QMetaObject.Slot0.class, java.util.Objects.requireNonNull(slot));
        if(parent instanceof io.qt.widgets.QWidget)
            return (io.qt.widgets.QWidget)parent;
        throw new IllegalArgumentException("Slot needs to be member of a QWidget instance.");
    }
    
    private static io.qt.widgets.QWidget parent(io.qt.core.QMetaObject.Connectable0 signal){
        if(signal.containingObject() instanceof io.qt.widgets.QWidget)
            return (io.qt.widgets.QWidget)signal.containingObject();
        throw new IllegalArgumentException("Signal needs to be member of a QWidget instance.");
    }
    
    public QShortcut(io.qt.gui.QKeySequence key,
            io.qt.core.QMetaObject.Slot0 slot,
            io.qt.core.Qt.ShortcutContext context)
    {
        this(key, parent(slot), context);
        activated.connect(slot);
    }

    public QShortcut(io.qt.gui.QKeySequence key,
            io.qt.core.QMetaObject.Slot0 slot)
    {
        this(key, slot, io.qt.core.Qt.ShortcutContext.WindowShortcut);
    }

    public QShortcut(io.qt.gui.QKeySequence key,
            io.qt.core.QMetaObject.Slot0 slot, io.qt.core.QMetaObject.Slot0 slot2,
            io.qt.core.Qt.ShortcutContext context)
    {
        this(key, parent(slot), context);
        activated.connect(slot);
        activatedAmbiguously.connect(slot2);
    }

    public QShortcut(io.qt.gui.QKeySequence key,
            io.qt.core.QMetaObject.Slot0 slot, io.qt.core.QMetaObject.Slot0 slot2)
    {
        this(key, slot, io.qt.core.Qt.ShortcutContext.WindowShortcut);
    }
    
    public QShortcut(io.qt.gui.QKeySequence key, io.qt.widgets.QWidget parent,
            io.qt.core.QMetaObject.Slot0 slot,
            io.qt.core.Qt.ShortcutContext context)
    {
        this(key, parent, context);
        activated.connect(slot);
    }

    public QShortcut(io.qt.gui.QKeySequence key, io.qt.widgets.QWidget parent,
            io.qt.core.QMetaObject.Slot0 slot)
    {
        this(key, parent, slot, io.qt.core.Qt.ShortcutContext.WindowShortcut);
    }

    public QShortcut(io.qt.gui.QKeySequence key, io.qt.widgets.QWidget parent,
            io.qt.core.QMetaObject.Slot0 slot, io.qt.core.QMetaObject.Slot0 slot2,
            io.qt.core.Qt.ShortcutContext context)
    {
        this(key, parent, context);
        activated.connect(slot);
        activatedAmbiguously.connect(slot2);
    }

    public QShortcut(io.qt.gui.QKeySequence key, io.qt.widgets.QWidget parent,
            io.qt.core.QMetaObject.Slot0 slot, io.qt.core.QMetaObject.Slot0 slot2)
    {
        this(key, parent, slot, io.qt.core.Qt.ShortcutContext.WindowShortcut);
    }
    
    public QShortcut(io.qt.gui.QKeySequence key,
            io.qt.core.QMetaObject.Connectable0 signal,
            io.qt.core.Qt.ShortcutContext context)
    {
        this(key, parent(signal), context);
        activated.connect(signal);
    }

    public QShortcut(io.qt.gui.QKeySequence key,
            io.qt.core.QMetaObject.Connectable0 signal)
    {
        this(key, signal, io.qt.core.Qt.ShortcutContext.WindowShortcut);
    }

    public QShortcut(io.qt.gui.QKeySequence key,
            io.qt.core.QMetaObject.Connectable0 signal, io.qt.core.QMetaObject.Connectable0 signal2,
            io.qt.core.Qt.ShortcutContext context)
    {
        this(key, parent(signal), context);
        activated.connect(signal);
        activatedAmbiguously.connect(signal2);
    }
    
    public QShortcut(io.qt.gui.QKeySequence key,
            io.qt.core.QMetaObject.Slot0 slot, io.qt.core.QMetaObject.Connectable0 signal2,
            io.qt.core.Qt.ShortcutContext context)
    {
        this(key, parent(slot), context);
        activated.connect(slot);
        activatedAmbiguously.connect(signal2);
    }
    
    public QShortcut(io.qt.gui.QKeySequence key,
            io.qt.core.QMetaObject.Connectable0 signal, io.qt.core.QMetaObject.Slot0 slot2,
            io.qt.core.Qt.ShortcutContext context)
    {
        this(key, parent(signal), context);
        activated.connect(signal);
        activatedAmbiguously.connect(slot2);
    }

    public QShortcut(io.qt.gui.QKeySequence key,
            io.qt.core.QMetaObject.Connectable0 signal, io.qt.core.QMetaObject.Connectable0 signal2)
    {
        this(key, signal, signal2, io.qt.core.Qt.ShortcutContext.WindowShortcut);
    }
    
    public QShortcut(io.qt.gui.QKeySequence key,
            io.qt.core.QMetaObject.Slot0 slot, io.qt.core.QMetaObject.Connectable0 signal2)
    {
        this(key, slot, signal2, io.qt.core.Qt.ShortcutContext.WindowShortcut);
    }
    
    public QShortcut(io.qt.gui.QKeySequence key,
            io.qt.core.QMetaObject.Connectable0 signal, io.qt.core.QMetaObject.Slot0 slot2)
    {
        this(key, signal, slot2, io.qt.core.Qt.ShortcutContext.WindowShortcut);
    }
    
    public QShortcut(io.qt.gui.QKeySequence key, io.qt.widgets.QWidget parent,
            io.qt.core.QMetaObject.Connectable0 signal,
            io.qt.core.Qt.ShortcutContext context)
    {
        this(key, parent, context);
        activated.connect(signal);
    }

    public QShortcut(io.qt.gui.QKeySequence key, io.qt.widgets.QWidget parent,
            io.qt.core.QMetaObject.Connectable0 signal)
    {
        this(key, parent, signal, io.qt.core.Qt.ShortcutContext.WindowShortcut);
    }

    public QShortcut(io.qt.gui.QKeySequence key, io.qt.widgets.QWidget parent,
            io.qt.core.QMetaObject.Connectable0 signal, io.qt.core.QMetaObject.Connectable0 signal2)
    {
        this(key, parent, signal, signal2, io.qt.core.Qt.ShortcutContext.WindowShortcut);
    }

    public QShortcut(io.qt.gui.QKeySequence key, io.qt.widgets.QWidget parent,
            io.qt.core.QMetaObject.Slot0 slot, io.qt.core.QMetaObject.Connectable0 signal2)
    {
        this(key, parent, slot, signal2, io.qt.core.Qt.ShortcutContext.WindowShortcut);
    }

    public QShortcut(io.qt.gui.QKeySequence key, io.qt.widgets.QWidget parent,
            io.qt.core.QMetaObject.Connectable0 signal, io.qt.core.QMetaObject.Slot0 slot2)
    {
        this(key, parent, signal, slot2, io.qt.core.Qt.ShortcutContext.WindowShortcut);
    }

    public QShortcut(io.qt.gui.QKeySequence key, io.qt.widgets.QWidget parent,
            io.qt.core.QMetaObject.Connectable0 signal, io.qt.core.QMetaObject.Connectable0 signal2,
            io.qt.core.Qt.ShortcutContext context)
    {
        this(key, parent, context);
        activated.connect(signal);
        activatedAmbiguously.connect(signal2);
    }

    public QShortcut(io.qt.gui.QKeySequence key, io.qt.widgets.QWidget parent,
            io.qt.core.QMetaObject.Slot0 slot, io.qt.core.QMetaObject.Connectable0 signal2,
            io.qt.core.Qt.ShortcutContext context)
    {
        this(key, parent, context);
        activated.connect(slot);
        activatedAmbiguously.connect(signal2);
    }

    public QShortcut(io.qt.gui.QKeySequence key, io.qt.widgets.QWidget parent,
            io.qt.core.QMetaObject.Connectable0 signal, io.qt.core.QMetaObject.Slot0 slot2,
            io.qt.core.Qt.ShortcutContext context)
    {
        this(key, parent, context);
        activated.connect(signal);
        activatedAmbiguously.connect(slot2);
    }
}// class

class QAbstractButton___ extends QAbstractButton {

        /**
         * Sets the shortcut to the key sequence for the given key string. For
         * example "Ctrl+O" gives CTRL+'O'. The strings "Ctrl", "Shift", "Alt" and
         * "Meta" are recognized, as well as their translated equivalents in the
         * "QShortcut" context (using QObject::tr()). Up to four key codes may be
         * entered by separating them with commas, e.g. "Alt+X,Ctrl+S,Q".
         *
         * @param key
         *            The description of the key sequence. Typically used with tr()
         *            so key sequences can be locale aware.
         */
        public final void setShortcut(String key) {
            setShortcut(new QKeySequence(key));
        }

        /**
         * Sets the shortcut to the key sequence for the given key. The result will
         * depend on the currently running platform. The key sequence will be based
         * on the first element in the list of key bindings for the key.
         *
         * @param key
         *            The key for which to select a key sequence
         */
        public final void setShortcut(QKeySequence.StandardKey key) {
            setShortcut(new QKeySequence(key));
        }

}// class

class QLayout___ extends QLayout {
    @io.qt.QtUninvokable
    public final void addWidget(io.qt.widgets.QWidget w){
        add_widget(w);
    }
}// class

class QBoxLayout___ extends QBoxLayout {
    @io.qt.QtUninvokable
    void add_widget(QWidget widget){
        addWidget(widget, 0);
    }
}// class

class QGridLayout___ extends QGridLayout {
    /**
     * Result class for <a href="https://doc.qt.io/qt/qgridlayout.html#getItemPosition">QGridLayout::getItemPosition(int,int*,int*,int*,int*)const</a>.
     */
    public static final class ItemInfo{
        private ItemInfo(int row, int column, int rowSpan, int columnSpan){
            this.row = row;
            this.column = column;
            this.rowSpan = rowSpan;
            this.columnSpan = columnSpan;
        }
        public final int row;
        public final int column;
        public final int rowSpan;
        public final int columnSpan;
    }
}// class

class QColorDialog__java_{
    /**
     * <p>See <a href="https://doc.qt.io/qt/qcolordialog.html#open">QColorDialog::open(QObject *, const char *)</a></p>
     */
    @io.qt.QtUninvokable
    public final void open(io.qt.core.QMetaObject.Slot1<io.qt.gui.QColor> selectedSlot) {
        io.qt.core.QMetaMethod metaMethod = io.qt.core.QMetaMethod.fromMethod(java.util.Objects.requireNonNull(selectedSlot));
        if(metaMethod==null || !metaMethod.isValid()) {
            throw new IllegalArgumentException("Unable to detect slot for given handle.");
        }
        if(metaMethod.parameterCount()!=1) {
            throw new IllegalArgumentException("Connected method does not take a single argument: "+metaMethod.cppMethodSignature());
        }
        if(metaMethod.parameterType(0)!=io.qt.core.QMetaType.Type.QColor.value()) {
            throw new IllegalArgumentException("Method does not take a single QColor argument: "+metaMethod.cppMethodSignature());
        }
        io.qt.core.QObject object = QtJambi_LibraryUtilities.internal.lambdaContext(io.qt.core.QMetaObject.Slot1.class, selectedSlot);
        if(object==null) {
            throw new IllegalArgumentException("Unable to determine QObject from given slot handle.");
        }
        open(object, metaMethod);
    }
    
    /**
     * <p>See <a href="https://doc.qt.io/qt/qcolordialog.html#open">QColorDialog::open(QObject *, const char *)</a></p>
     */
    @io.qt.QtUninvokable
    public final void open(io.qt.core.QMetaObject.Connectable1<io.qt.gui.QColor> selectedSignal) {
        io.qt.core.QMetaMethod metaMethod = io.qt.core.QMetaMethod.fromSignal(selectedSignal);
        if(metaMethod==null || !metaMethod.isValid()) {
            throw new IllegalArgumentException("Unable to detect signal for given handle.");
        }
        if(metaMethod.parameterCount()!=1) {
            throw new IllegalArgumentException("Connected method does not take a single argument: "+metaMethod.cppMethodSignature());
        }
        if(metaMethod.parameterType(0)!=io.qt.core.QMetaType.Type.QColor.value()) {
            throw new IllegalArgumentException("Method does not take a single QColor argument: "+metaMethod.cppMethodSignature());
        }
        if(!(selectedSignal.containingObject() instanceof io.qt.core.QObject)) {
            throw new IllegalArgumentException("Unable to determine QObject from given signal handle.");
        }
        open((io.qt.core.QObject)selectedSignal.containingObject(), metaMethod);
    }
    
    private native void open(io.qt.core.QObject obj, io.qt.core.QMetaMethod metaMethod);
}// class

class QFontDialog__java_ extends QFontDialog {
    /**
     * <p>See <a href="https://doc.qt.io/qt/qfontdialog.html#open">QFontDialog::open(QObject *, const char *)</a></p>
     */
    @io.qt.QtUninvokable
    public final void open(io.qt.core.QMetaObject.Slot1<io.qt.gui.QFont> selectedSlot) {
        io.qt.core.QMetaMethod metaMethod = io.qt.core.QMetaMethod.fromMethod(java.util.Objects.requireNonNull(selectedSlot));
        if(metaMethod==null || !metaMethod.isValid()) {
            throw new IllegalArgumentException("Unable to detect slot for given handle.");
        }
        if(metaMethod.parameterCount()!=1) {
            throw new IllegalArgumentException("Connected method does not take a single argument: "+metaMethod.cppMethodSignature());
        }
        if(metaMethod.parameterType(0)!=io.qt.core.QMetaType.Type.QFont.value()) {
            throw new IllegalArgumentException("Method does not take a single QFont argument: "+metaMethod.cppMethodSignature());
        }
        io.qt.core.QObject object = QtJambi_LibraryUtilities.internal.lambdaContext(io.qt.core.QMetaObject.Slot1.class, selectedSlot);
        if(object==null) {
            throw new IllegalArgumentException("Unable to determine QObject from given slot handle.");
        }
        open(object, metaMethod);
    }
    
    /**
     * <p>See <a href="https://doc.qt.io/qt/qfontdialog.html#open">QFontDialog::open(QObject *, const char *)</a></p>
     */
    @io.qt.QtUninvokable
    public final void open(io.qt.core.QMetaObject.Connectable1<io.qt.gui.QFont> selectedSignal) {
        io.qt.core.QMetaMethod metaMethod = io.qt.core.QMetaMethod.fromSignal(selectedSignal);
        if(metaMethod==null || !metaMethod.isValid()) {
            throw new IllegalArgumentException("Unable to detect signal for given handle.");
        }
        if(metaMethod.parameterCount()!=1) {
            throw new IllegalArgumentException("Connected method does not take a single argument: "+metaMethod.cppMethodSignature());
        }
        if(metaMethod.parameterType(0)!=io.qt.core.QMetaType.Type.QFont.value()) {
            throw new IllegalArgumentException("Method does not take a single QFont argument: "+metaMethod.cppMethodSignature());
        }
        if(!(selectedSignal.containingObject() instanceof io.qt.core.QObject)) {
            throw new IllegalArgumentException("Unable to determine QObject from given signal handle.");
        }
        open((io.qt.core.QObject)selectedSignal.containingObject(), metaMethod);
    }
    
    private native void open(io.qt.core.QObject obj, io.qt.core.QMetaMethod metaMethod);
}// class

class QFileDialog__java_ extends QFileDialog {
    /**
     * Result class for <a href="https://doc.qt.io/qt/qfiledialog.html#getOpenFileName">QFileDialog::getOpenFileName(QWidget*,QString,QString,QString,QString*,Options)</a>,
     * <a href="https://doc.qt.io/qt/qfiledialog.html#getOpenFileNames">QFileDialog::getOpenFileNames(QWidget*,QString,QString,QString,QString*,Options)</a>,
     * <a href="https://doc.qt.io/qt/qfiledialog.html#getOpenFileUrl">QFileDialog::getOpenFileUrl(QWidget*,QString,QUrl,QString,QString*,Options,QStringList)</a>,
     * <a href="https://doc.qt.io/qt/qfiledialog.html#getOpenFileUrls">QFileDialog::getOpenFileUrls(QWidget*,QString,QUrl,QString,QString*,Options,QStringList)</a>,
     * <a href="https://doc.qt.io/qt/qfiledialog.html#getSaveFileName">QFileDialog::getSaveFileName(QWidget*,QString,QString,QString,QString*,Options)</a> and
     * <a href="https://doc.qt.io/qt/qfiledialog.html#getSaveFileUrl">QFileDialog::getSaveFileUrl(QWidget*,QString,QUrl,QString,QString*,Options,QStringList)</a>.
     */
    public static final class Result<R> {
        @io.qt.NativeAccess
        private Result(R result, String selectedFilter) {
            this.result = result;
            this.selectedFilter = selectedFilter;
        }

        public final R result;
        public final String selectedFilter;
    }
    
    /**
     * <p>See <a href="https://doc.qt.io/qt/qfiledialog.html#getExistingDirectoryUrl">QFileDialog::getExistingDirectoryUrl(QWidget*,QString,QUrl,Options,QStringList)</a></p>
     */
    public static io.qt.core.QUrl getExistingDirectoryUrl(io.qt.widgets.QWidget parent, java.lang.String caption, io.qt.core.QUrl dir, java.util.Collection<java.lang.String> supportedSchemes, io.qt.widgets.QFileDialog.Option... options){
        return getExistingDirectoryUrl(parent, caption, dir, new io.qt.widgets.QFileDialog.Options(options), supportedSchemes);
    }
    
    /**
     * <p>See <a href="https://doc.qt.io/qt/qfiledialog.html#getOpenFileUrl">QFileDialog::getOpenFileUrl(QWidget*,QString,QUrl,QString,QString*,Options,QStringList)</a></p>
     */
    public static io.qt.widgets.QFileDialog.Result<io.qt.core.QUrl> getOpenFileUrl(io.qt.widgets.QWidget parent, java.lang.String caption, io.qt.core.QUrl dir, java.lang.String filter, java.util.Collection<java.lang.String> supportedSchemes, io.qt.widgets.QFileDialog.Option... options){
        return getOpenFileUrl(parent, caption, dir, filter, io.qt.widgets.QFileDialog.Option.flags(options), supportedSchemes);
    }
    
    /**
     * <p>See <a href="https://doc.qt.io/qt/qfiledialog.html#getOpenFileUrls">QFileDialog::getOpenFileUrls(QWidget*,QString,QUrl,QString,QString*,Options,QStringList)</a></p>
     */
    public static io.qt.widgets.QFileDialog.Result<java.util.List<io.qt.core.QUrl>> getOpenFileUrls(io.qt.widgets.QWidget parent, java.lang.String caption, io.qt.core.QUrl dir, java.lang.String filter, java.util.Collection<java.lang.String> supportedSchemes, io.qt.widgets.QFileDialog.Option... options){
        return getOpenFileUrls(parent, caption, dir, filter, io.qt.widgets.QFileDialog.Option.flags(options), supportedSchemes);
    }
    
    /**
     * <p>See <a href="https://doc.qt.io/qt/qfiledialog.html#getSaveFileUrl">QFileDialog::getSaveFileUrl(QWidget*,QString,QUrl,QString,QString*,Options,QStringList)</a></p>
     */
    public static io.qt.widgets.QFileDialog.Result<io.qt.core.QUrl> getSaveFileUrl(io.qt.widgets.QWidget parent, java.lang.String caption, io.qt.core.QUrl dir, java.lang.String filter, java.util.Collection<java.lang.String> supportedSchemes, io.qt.widgets.QFileDialog.Option... options){
        return getSaveFileUrl(parent, caption, dir, filter, io.qt.widgets.QFileDialog.Option.flags(options), supportedSchemes);
    }
    
    /**
     * <p>See <a href="https://doc.qt.io/qt/qfiledialog.html#open">QFileDialog::open(QObject *, const char *)</a></p>
     */
    @io.qt.QtUninvokable
    public final void open(io.qt.core.QMetaObject.Slot1<?> selectedSlot) {
        io.qt.core.QMetaMethod metaMethod = io.qt.core.QMetaMethod.fromMethod(java.util.Objects.requireNonNull(selectedSlot));
        if(metaMethod==null || !metaMethod.isValid()) {
            throw new IllegalArgumentException("Unable to detect slot for given handle.");
        }
        if(metaMethod.parameterCount()!=1) {
            throw new IllegalArgumentException("Connected method does not take a single argument: "+metaMethod.cppMethodSignature());
        }
        if(fileMode()==FileMode.ExistingFiles) {
            if(metaMethod.parameterType(0)!=io.qt.core.QMetaType.Type.QStringList.value()) {
                throw new IllegalArgumentException("Method does not take a single String list argument: "+metaMethod.cppMethodSignature());
            }
        }else {
            if(metaMethod.parameterType(0)!=io.qt.core.QMetaType.Type.QString.value()) {
                throw new IllegalArgumentException("Method does not take a single String argument: "+metaMethod.cppMethodSignature());
            }
        }
        io.qt.core.QObject object = QtJambi_LibraryUtilities.internal.lambdaContext(io.qt.core.QMetaObject.Slot1.class, selectedSlot);
        if(object==null) {
            throw new IllegalArgumentException("Unable to determine QObject from given slot handle.");
        }
        open(object, metaMethod);
    }
    
    /**
     * <p>See <a href="https://doc.qt.io/qt/qfiledialog.html#open">QFileDialog::open(QObject *, const char *)</a></p>
     */
    @io.qt.QtUninvokable
    public final void open(io.qt.core.QMetaObject.Connectable1<?> selectedSignal) {
        io.qt.core.QMetaMethod metaMethod = io.qt.core.QMetaMethod.fromSignal(selectedSignal);
        if(metaMethod==null || !metaMethod.isValid()) {
            throw new IllegalArgumentException("Unable to detect signal for given handle.");
        }
        if(metaMethod.parameterCount()!=1) {
            throw new IllegalArgumentException("Connected method does not take a single argument: "+metaMethod.cppMethodSignature());
        }
        if(fileMode()==FileMode.ExistingFiles) {
            if(metaMethod.parameterType(0)!=io.qt.core.QMetaType.Type.QStringList.value()) {
                throw new IllegalArgumentException("Method does not take a single String list argument: "+metaMethod.cppMethodSignature());
            }
        }else {
            if(metaMethod.parameterType(0)!=io.qt.core.QMetaType.Type.QString.value()) {
                throw new IllegalArgumentException("Method does not take a single String argument: "+metaMethod.cppMethodSignature());
            }
        }
        if(!(selectedSignal.containingObject() instanceof io.qt.core.QObject)) {
            throw new IllegalArgumentException("Unable to determine QObject from given signal handle.");
        }
        open((io.qt.core.QObject)selectedSignal.containingObject(), metaMethod);
    }
    
    private native void open(io.qt.core.QObject obj, io.qt.core.QMetaMethod metaMethod);
}// class

class QInputDialog__java_ extends QInputDialog {
    /**
     * <p>See <a href="https://doc.qt.io/qt/qinputdialog.html#open">QInputDialog::open(QObject *, const char *)</a></p>
     */
    @io.qt.QtUninvokable
    public final void open(io.qt.core.QMetaObject.Slot0 selectedSlot) {
        io.qt.core.QMetaMethod metaMethod = io.qt.core.QMetaMethod.fromMethod(java.util.Objects.requireNonNull(selectedSlot));
        if(metaMethod==null || !metaMethod.isValid()) {
            throw new IllegalArgumentException("Unable to detect slot for given handle.");
        }
        if(metaMethod.parameterCount()>0) {
            throw new IllegalArgumentException("Connected method must not take any arguments: "+metaMethod.cppMethodSignature());
        }
        io.qt.core.QObject object = QtJambi_LibraryUtilities.internal.lambdaContext(io.qt.core.QMetaObject.Slot0.class, selectedSlot);
        if(object==null) {
            throw new IllegalArgumentException("Unable to determine QObject from given slot handle.");
        }
        open(object, metaMethod);
    }
    
    /**
     * <p>See <a href="https://doc.qt.io/qt/qinputdialog.html#open">QInputDialog::open(QObject *, const char *)</a></p>
     */
    @io.qt.QtUninvokable
    public final void open(io.qt.core.QMetaObject.Slot1<?> selectedSlot) {
        io.qt.core.QMetaMethod metaMethod = io.qt.core.QMetaMethod.fromMethod(java.util.Objects.requireNonNull(selectedSlot));
        if(metaMethod==null || !metaMethod.isValid()) {
            throw new IllegalArgumentException("Unable to detect slot for given handle.");
        }
        if(metaMethod.parameterCount()>0) {
            throw new IllegalArgumentException("Connected method does not take a single argument: "+metaMethod.cppMethodSignature());
        }
        if(metaMethod.parameterType(0)!=io.qt.core.QMetaType.Type.QString.value()
            && metaMethod.parameterType(0)!=io.qt.core.QMetaType.Type.Int.value()
            && metaMethod.parameterType(0)!=io.qt.core.QMetaType.Type.UInt.value()
            && metaMethod.parameterType(0)!=io.qt.core.QMetaType.Type.Double.value()) {
            throw new IllegalArgumentException("Method does not take a single String, int or double argument: "+metaMethod.cppMethodSignature());
        }
        io.qt.core.QObject object = QtJambi_LibraryUtilities.internal.lambdaContext(io.qt.core.QMetaObject.Slot1.class, selectedSlot);
        if(object==null) {
            throw new IllegalArgumentException("Unable to determine QObject from given slot handle.");
        }
        open(object, metaMethod);
    }
    
    /**
     * <p>See <a href="https://doc.qt.io/qt/qinputdialog.html#open">QInputDialog::open(QObject *, const char *)</a></p>
     */
    @io.qt.QtUninvokable
    public final void open(io.qt.core.QMetaObject.Connectable1<?> selectedSignal) {
        io.qt.core.QMetaMethod metaMethod = io.qt.core.QMetaMethod.fromSignal(selectedSignal);
        if(metaMethod==null || !metaMethod.isValid()) {
            throw new IllegalArgumentException("Unable to detect signal for given handle.");
        }
        if(metaMethod.parameterCount()>0) {
            throw new IllegalArgumentException("Connected method does not take a single argument: "+metaMethod.cppMethodSignature());
        }
        if(metaMethod.parameterType(0)!=io.qt.core.QMetaType.Type.QString.value()
            && metaMethod.parameterType(0)!=io.qt.core.QMetaType.Type.Int.value()
            && metaMethod.parameterType(0)!=io.qt.core.QMetaType.Type.UInt.value()
            && metaMethod.parameterType(0)!=io.qt.core.QMetaType.Type.Double.value()) {
            throw new IllegalArgumentException("Method does not take a single String, int or double argument: "+metaMethod.cppMethodSignature());
        }
        if(!(selectedSignal.containingObject() instanceof io.qt.core.QObject)) {
            throw new IllegalArgumentException("Unable to determine QObject from given signal handle.");
        }
        open((io.qt.core.QObject)selectedSignal.containingObject(), metaMethod);
    }
    
    private native void open(io.qt.core.QObject obj, io.qt.core.QMetaMethod metaMethod);
}// class

class QAbstractScrollArea___ extends QAbstractScrollArea {

        public QPaintEngine paintEngine() {
            throw new RuntimeException("Cannot open a painter directly on a QAbstractScrollArea, open QPainter on its viewport instead...");
        }

}// class

class QSplitter___ extends QSplitter {
        /**
         * Result class for <a href="https://doc.qt.io/qt/qsplitter.html#getRange">QSplitter::getRange(int,int*,int*)const</a>.
         */
        public static final class Range {
            @io.qt.NativeAccess
            private Range(int min, int max) {
                minimum = min;
                maximum = max;
            }

            public final int minimum;
            public final int maximum;
        }
}// class

class QAction___ extends QAction {

        private QActionGroup __rcActionGroup = null;

        /**
         * Sets the shortcut to the key sequence for the given key string. For
         * example "Ctrl+O" gives CTRL+'O'. The strings "Ctrl", "Shift", "Alt" and
         * "Meta" are recognized, as well as their translated equivalents in the
         * "QShortcut" context (using QObject::tr()). Up to four key codes may be
         * entered by separating them with commas, e.g. "Alt+X,Ctrl+S,Q".
         *
         * @param key
         *            The description of the key sequence. Typically used with tr()
         *            so key sequences can be locale aware.
         */
        public final void setShortcut(String key) {
            setShortcut(new QKeySequence(key));
        }

        /**
         * Sets the shortcut to the key sequence for the given key. The result will
         * depend on the currently running platform. The key sequence will be based
         * on the first element in the list of key bindings for the key.
         *
         * @param key
         *            The key for which to select a key sequence
         */
        public final void setShortcut(QKeySequence.StandardKey key) {
            setShortcut(new QKeySequence(key));
        }

        public final void setIcon(QPixmap pm) {
            setIcon(new QIcon(pm));
        }

}// class

class QApplication___ extends QApplication {

        public static QApplication initialize(String args[]) {
            return io.qt.core.QCoreApplication.initialize(null, args, QApplication::new);
        }

        public static QApplication initialize(String applicationName, String args[]) {
            return io.qt.core.QCoreApplication.initialize(applicationName, args, QApplication::new);
        }

        public static void shutdown() {
            io.qt.core.QCoreApplication.shutdown();
        }
        
        public static QApplication instance() {
            io.qt.core.QCoreApplication app = io.qt.core.QCoreApplication.instance();
            if (app instanceof QApplication)
                return (QApplication) app;
            return null;
        }
}// class

class QFormLayout___ extends QFormLayout {
    /**
     * Result class for <a href="https://doc.qt.io/qt/qformlayout.html#getItemPosition">QFormLayout::getItemPosition(int,int*,QFormLayout::ItemRole*)const</a>,
     * <a href="https://doc.qt.io/qt/qformlayout.html#getLayoutPosition">QFormLayout::getLayoutPosition(QLayout*,int*,QFormLayout::ItemRole*)const</a> and
     * <a href="https://doc.qt.io/qt/qformlayout.html#getWidgetPosition">QFormLayout::getWidgetPosition(QWidget*,int*,QFormLayout::ItemRole*)const</a>.
     */
    public static final class ItemInfo{
        private ItemInfo(int row, ItemRole role){
            this.row = row;
            this.role = role;
        }
        public final int row;
        public final ItemRole role;
    }
}// class

class QGraphicsWidget___ extends QGraphicsWidget {

        /**
         * @see #getWindowFrameMargins(double[])
         */
        @io.qt.QtUninvokable
        public final io.qt.core.QMarginsF windowFrameMargins() {
            double[] mrg = {0.0, 0.0, 0.0, 0.0};
            getWindowFrameMargins(mrg);
            return new io.qt.core.QMarginsF(mrg[0], mrg[1], mrg[2], mrg[3]);
        }
}// class

class QListWidget___ extends QListWidget {

        /**
         * Inserts an item with the text label at the end of the list widget.
         *
         * @param label The text of the new item.
         */
        public final void addItem(String label) {
            addItem(new QListWidgetItem(label, this));
        }

        /**
         * Inserts items with the text labels at the end of the list widget.
         *
         * @param labels The collection of labels for the new items.
         */
        public final void addItems(java.util.List<String> labels) {
        for (String label : labels)
                addItem(label);
        }

        /**
         * This is an overloaded member function, provided for convenience.
         * Inserts an item with the text label in the list widget at the position given by row.
         *
         * @param row The position in which to insert the new item.
         * @param label The text of the new item.
         */
        public final void insertItem(int row, String label) {
            insertItem(row, new QListWidgetItem(label, this));
        }

        /**
         * Inserts items from the list of labels into the list, starting at the given row.
         *
         * @param row The position in which to insert the new items.
         * @param labels The collection of labels for the new items.
         */
        public final void insertItems(int row, java.util.List<String> labels) {
        for (String label : labels)
                insertItem(row++, label);
        }
}// class

class QGraphicsScene___ extends QGraphicsScene {
        /**
         * Equivalent to addEllipse(rect, null, null)
         */
        public final QGraphicsEllipseItem addEllipse(io.qt.core.QRectF rect) {
            return addEllipse(rect, null);
        }

        /**
         * Equivalent to addEllipse(rect, pen, null)
         */
        public final QGraphicsEllipseItem addEllipse(io.qt.core.QRectF rect, QPen pen) {
            return addEllipse(rect, pen, null);
        }


        /**
         * Creates and adds an ellipse item to the scene, and returns the item
         * reference. The geometry of the ellipse is defined by rect, and its pen
         * and brush are initialized to pen and brush.
         *
         * Note that the item's geometry is provided in item coordinates, and its
         * position is initialized to (0, 0).
         *
         * If the item is visible (i.e., QGraphicsItem::isVisible() returns true),
         * QGraphicsScene will emit changed() once control goes back to the event
         * loop.
         *
         * @param rect The bounding rectangle of the ellipse.
         * @param pen The pen for the resulting QGraphicsEllipseItem.
         * @param brush The brush for the resulting QGraphicsEllipseItem.
         * @return The resulting item.
         */
        public final QGraphicsEllipseItem addEllipse(io.qt.core.QRectF rect, QPen pen, QBrush brush) {
            return addEllipse(rect.x(), rect.y(), rect.width(), rect.height(), pen, brush);
        }

        /**
         * Equivalent to addEllipse(x, y, w, h, null, null)
         */
        public final QGraphicsEllipseItem addEllipse(double x, double y, double w, double h) {
            return addEllipse(x, y, w, h, null);
        }

        /**
         * Equivalent to addEllipse(x, y, w, h, pen, null)
         */
        public final QGraphicsEllipseItem addEllipse(double x, double y, double w, double h, QPen pen) {
            return addEllipse(x, y, w, h, pen, null);
        }

        /**
         * Creates and adds an ellipse item to the scene, and returns the item
         * reference. The geometry of the ellipse is defined by x, y, w, h, and its pen
         * and brush are initialized to pen and brush.
         *
         * Note that the item's geometry is provided in item coordinates, and its
         * position is initialized to (0, 0).
         *
         * If the item is visible (i.e., QGraphicsItem.isVisible() returns true),
         * QGraphicsScene will emit changed once control goes back to the event
         * loop.
         *
         * @param x The left horizontal coordinate of the ellipse's bounding rectangle.
         * @param y The top vertical coordinate of the ellipse's bounding rectangle.
         * @param w The width of the ellipse's bounding rectangle.
         * @param h The height of the ellipse's bounding rectangle.
         * @param pen The pen for the resulting QGraphicsEllipseItem.
         * @param brush The brush for the resulting QGraphicsEllipseItem.
         * @return The resulting item.
         */
        public final QGraphicsEllipseItem addEllipse(double x, double y, double w, double h, QPen pen, QBrush brush) {
            QGraphicsEllipseItem item = new QGraphicsEllipseItem(x, y, w, h);
            item.setPen(pen);
            item.setBrush(brush);

            addItem(item);

            return item;
        }

        /**
         * Equivalent to addLine(line, null)
         */
        public final QGraphicsLineItem addLine(QLineF line) {
            return addLine(line, null);
        }

        /**
         * Creates and adds a line item to the scene, and returns the item
         * reference. The geometry of the line is defined by line, and its pen
         * is initialized to pen.
         *
         * Note that the item's geometry is provided in item coordinates, and its
         * position is initialized to (0, 0).
         *
         * If the item is visible (i.e., QGraphicsItem.isVisible() returns true),
         * QGraphicsScene will emit changed once control goes back to the event
         * loop.
         *
         * @param line The definition of the line.
         * @param pen The pen with which to draw the line.
         * @return The resulting item.
         */
        public final QGraphicsLineItem addLine(QLineF line, QPen pen) {
            return addLine(line.x1(), line.y1(), line.x2(), line.y2(), pen);
        }

        /**
         * Equivalent to addLine(x1, y1, x2, y2, null)
         */
        public final QGraphicsLineItem addLine(double x1, double y1, double x2, double y2) {
            return addLine(x1, y1, x2, y2, null);
        }

        /**
         * Creates and adds a line item to the scene, and returns the item
         * reference. The geometry of the line is defined by x1, y1, x2, y2, and its pen
         * is initialized to pen.
         *
         * Note that the item's geometry is provided in item coordinates, and its
         * position is initialized to (0, 0).
         *
         * If the item is visible (i.e., QGraphicsItem.isVisible() returns true),
         * QGraphicsScene will emit changed once control goes back to the event
         * loop.
         *
         * @param x1 The first horizontal coordinate of the line.
         * @param y1 The first vertical coordinate of the line.
         * @param x2 The second horizontal coordinate of the line.
         * @param y2 The second vertical coordinate of the line.
         * @param pen The pen with which to draw the line.
         * @return The resulting item.
         */
        public final QGraphicsLineItem addLine(double x1, double y1, double x2, double y2, QPen pen) {
            QGraphicsLineItem item = new QGraphicsLineItem(x1, y1, x2, y2);
            item.setPen(pen);

            addItem(item);

            return item;
        }


        /**
         * Equivalent to addPath(path, null, null)
         */
        public final QGraphicsPathItem addPath(QPainterPath path) {
            return addPath(path, null);
        }

        /**
         * Equivalent to addPath(path, pen, null)
         */
        public final QGraphicsPathItem addPath(QPainterPath path, QPen pen) {
            return addPath(path, pen, null);
        }
        /**
         * Creates and adds a path item to the scene, and returns the item
         * reference. The geometry of the path is defined by path, and its pen and
         * brush are initialized to pen and brush.
         *
         * Note that the item's geometry is provided in item coordinates, and its
         * position is initialized to (0, 0).
         *
         * If the item is visible (i.e., QGraphicsItem.isVisible() returns true),
         * QGraphicsScene will emit changed once control goes back to the event
         * loop.
         *
         * @param path The definition of the path.
         * @param pen The pen for drawing the path.
         * @param brush The brush for drawing the path.
         * @return The resulting item.
         */
        public final QGraphicsPathItem addPath(QPainterPath path, QPen pen, QBrush brush) {
            QGraphicsPathItem item = new QGraphicsPathItem(path);
            item.setPen(pen);
            item.setBrush(brush);

            addItem(item);

            return item;
        }

        /**
         * Creates and adds a pixmap item to the scene, and returns the item
         * reference. The pixmap is defined by pixmap.
         *
         * Note that the item's geometry is provided in item coordinates, and its
         * position is initialized to (0, 0).
         *
         * If the item is visible (i.e., QGraphicsItem.isVisible() returns true),
         * QGraphicsScene will emit changed once control goes back to the event
         * loop.
         *
         * @param pixmap The pixmap for which to create a graphics item.
         * @return The resulting item.
         */
        public final QGraphicsPixmapItem addPixmap(QPixmap pixmap) {
            QGraphicsPixmapItem item = new QGraphicsPixmapItem(pixmap);

            addItem(item);

            return item;
        }

        /**
         * Equivalent to addPolygon(polygon, null, null)
         */
        public final QGraphicsPolygonItem addPolygon(QPolygonF polygon) {
            return addPolygon(polygon, null);
        }

        /**
         * Equivalent to addPolygon(polygon, pen, null)
         */
        public final QGraphicsPolygonItem addPolygon(QPolygonF polygon, QPen pen) {
            return addPolygon(polygon, pen, null);
        }

        /**
         * Creates and adds a polygon item to the scene, and returns the item
         * reference. The polygon is defined by polygon, and its pen and
         * brush are initialized to pen and brush.
         *
         * Note that the item's geometry is provided in item coordinates, and its
         * position is initialized to (0, 0).
         *
         * If the item is visible (i.e., QGraphicsItem.isVisible() returns true),
         * QGraphicsScene will emit changed once control goes back to the event
         * loop.
         *
         * @param polygon The definition of the polygon.
         * @param pen The pen with which to draw the polygon.
         * @param brush The brush with which to draw the polygon.
         * @return The resulting item.
         */
        public final QGraphicsPolygonItem addPolygon(QPolygonF polygon, QPen pen, QBrush brush) {
            QGraphicsPolygonItem item = new QGraphicsPolygonItem(polygon);
            item.setPen(pen);
            item.setBrush(brush);

            addItem(item);

            return item;
        }

        /**
         * Equivalent to addRect(rect, null, null)
         */
        public final QGraphicsRectItem addRect(io.qt.core.QRectF rect) {
            return addRect(rect, null);
        }

        /**
         * Equivalent to addRect(rect, pen, null)
         */
        public final QGraphicsRectItem addRect(io.qt.core.QRectF rect, QPen pen) {
            return addRect(rect, pen, null);
        }

        /**
         * Creates and adds a rectangle item to the scene, and returns the item
         * reference. The geometry of the rectangle is defined by rect, and its pen
         * and brush are initialized to pen and brush.
         *
         * Note that the item's geometry is provided in item coordinates, and its
         * position is initialized to (0, 0). For example, if a QRect(50, 50, 100,
         * 100) is added, its top-left corner will be at (50, 50) relative to the
         * origin in the item's coordinate system.
         *
         * If the item is visible (i.e., QGraphicsItem.isVisible() returns true),
         * QGraphicsScene will emit changed once control goes back to the event
         * loop.
         *
         * @param rect The definition of the rectangle.
         * @param pen The pen with which to draw the rectangle.
         * @param brush The brush with which to draw the rectangle.
         * @return The resulting item.
         */
        public final QGraphicsRectItem addRect(io.qt.core.QRectF rect, QPen pen, QBrush brush) {
            return addRect(rect.x(), rect.y(), rect.width(), rect.height(), pen, brush);
        }

        /**
         * Equivalent to addRect(x, y, w, h, null, null)
         */
        public final QGraphicsRectItem addRect(double x, double y, double w, double h) {
            return addRect(x, y, w, h, null);
        }

        /**
         * Equivalent to addRect(x, y, w, h, pen, null)
         */
        public final QGraphicsRectItem addRect(double x, double y, double w, double h, QPen pen) {
            return addRect(x, y, w, h, pen, null);
        }

        /**
         * Creates and adds a rectangle item to the scene, and returns the item
         * reference. The geometry of the rectangle is defined by x, y, w, h, and its pen
         * and brush are initialized to pen and brush.
         *
         * Note that the item's geometry is provided in item coordinates, and its
         * position is initialized to (0, 0).
         *
         * If the item is visible (i.e., QGraphicsItem.isVisible() returns true),
         * QGraphicsScene will emit changed once control goes back to the event
         * loop.
         *
         * @param x The left horizontal coordinate of the rectangle.
         * @param y The top vertical coordinate of the rectangle.
         * @param w The width of the rectangle.
         * @param h The height of the rectangle.
         * @param pen The pen with which to draw the rectangle.
         * @param brush The brush with which to draw the rectangle.
         * @return The resulting item.
         */
        public final QGraphicsRectItem addRect(double x, double y, double w, double h, QPen pen, QBrush brush) {
            QGraphicsRectItem item = new QGraphicsRectItem(x, y, w, h);
            item.setPen(pen);
            item.setBrush(brush);

            addItem(item);

            return item;
        }

        /**
         * Equivalent to addSimpleText(text, null)
         */
        public final QGraphicsSimpleTextItem addSimpleText(String text) {
            return addSimpleText(text, null);
        }

        /**
         * Creates and adds a QGraphicsSimpleTextItem to the scene, and returns the
         * item reference. The text string is initialized to text, and its font is
         * initialized to font.
         *
         * The item's position is initialized to (0, 0).
         *
         * If the item is visible (i.e., QGraphicsItem.isVisible() returns true),
         * QGraphicsScene will emit changed once control goes back to the event
         * loop.
         *
         * @param text The text to add to the scene.
         * @param font The font to use for displaying the text.
         * @return The resulting item.
         */
        public final QGraphicsSimpleTextItem addSimpleText(String text, QFont font) {
            QGraphicsSimpleTextItem item = new QGraphicsSimpleTextItem(text);
            item.setFont(font);

            addItem(item);

            return item;
        }

        /**
         * Equivalent to addText(text, null)
         */
        public final QGraphicsTextItem addText(String text) {
            return addText(text, null);
        }

        /**
         * Creates and adds a text item to the scene, and returns the item
         * reference. The text string is initialized to text, and its font
         * is initialized to font.
         *
         * The item's position is initialized to (0, 0).
         *
         * If the item is visible (i.e., QGraphicsItem.isVisible() returns true),
         * QGraphicsScene will emit changed once control goes back to the event
         * loop.
         *
         * @param text The text to add to the scene.
         * @param font The font to use for displaying the text.
         * @return The resulting item.
         */
        public final QGraphicsTextItem addText(String text, QFont font) {
            QGraphicsTextItem item = new QGraphicsTextItem(text);
            item.setFont(font);

            addItem(item);

            return item;
        }

}// class

class QGraphicsItem___{
    /**
     * Result class for <a href="https://doc.qt.io/qt/qgraphicsitem.html#isBlockedByModalPanel">QGraphicsItem::isBlockedByModalPanel(QGraphicsItem**)const</a>.
     */
    public static final class BlockedByModalPanelInfo{
        private BlockedByModalPanelInfo(boolean isBlockedByModalPanel,
                QGraphicsItem modalPanel) {
            super();
            this.isBlockedByModalPanel = isBlockedByModalPanel;
            this.modalPanel = modalPanel;
        }
        public final boolean isBlockedByModalPanel;
        public final QGraphicsItem modalPanel;
    }
}// class

class QStyle___{
    @io.qt.QtUninvokable
    private static SubControl findSubControl(int control, int subControl) {
        SubControl[] subControls = SubControl.values();
        ComplexControl complexControl = ComplexControl.resolve(control);
        String complexControlName;
        switch(complexControl) {
        case CC_MdiControls:
            complexControlName = "SC_Mdi";
            break;
        default:
            complexControlName = complexControl.name();
            complexControlName = "S"+complexControlName.substring(1);
            break;
        }
        for (SubControl sc : subControls) {
            if(sc.value()==subControl && sc.name().startsWith(complexControlName))
                return sc;
        }
        return SubControl.resolve(subControl);
    }
}// class



