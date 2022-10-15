QTJAMBILIB = QtJambiQml
TARGET = $$QTJAMBILIB

VERSION = $$section(QT_VERSION, ., 0, 1).$$QTJAMBI_PATCH_VERSION

include(../qtjambi/qtjambi_include.pri)
exists($$QTJAMBI_BUILDDIR): include($$QTJAMBI_BUILDDIR/generator/out/cpp/$$QTJAMBILIB/generated.pri)

HEADERS += qqmllistproperty.h \
    qmlcreateparentfunction.h \
    qmlattachedpropertiesfunction.h \
    qmlcreatorfunction.h \
    qtjambi_qml.h \
    qtjambi_qml_hashes.h \
    qtjambi_qml_repository.h
SOURCES += qmlregistry.cpp qqmllistproperty.cpp \
    qmlcreatorfunction.cpp \
    qmlcreateparentfunction.cpp \
    qmlattachedpropertiesfunction.cpp \
    qtjambi_qml_repository.cpp

DEFINES += QTJAMBI_QML_EXPORT

QT = core qml core-private qml-private

msvc:QMAKE_CXXFLAGS += /bigobj

