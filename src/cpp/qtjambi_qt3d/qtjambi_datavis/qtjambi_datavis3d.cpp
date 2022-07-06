#include "qtjambi_datavis3d_hashes.h"

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)

void registerHashFunction_QBarDataArray(){ ::registerHashFunction(typeid(QtDataVisualization::QBarDataArray), [](const void* ptr, hash_type seed)->hash_type{ return !ptr ? 0 : qHash(*reinterpret_cast<const QtDataVisualization::QBarDataArray*>(ptr), seed); }); }

void registerHashFunction_QBarDataRow(){ ::registerHashFunction(typeid(QtDataVisualization::QBarDataRow), [](const void* ptr, hash_type seed)->hash_type{ return !ptr ? 0 : qHash(*reinterpret_cast<const QtDataVisualization::QBarDataRow*>(ptr), seed); }); }

void registerHashFunction_QSurfaceDataArray(){ ::registerHashFunction(typeid(QtDataVisualization::QSurfaceDataArray), [](const void* ptr, hash_type seed)->hash_type{ return !ptr ? 0 : qHash(*reinterpret_cast<const QtDataVisualization::QSurfaceDataArray*>(ptr), seed); }); }

void registerHashFunction_QSurfaceDataRow(){ ::registerHashFunction(typeid(QtDataVisualization::QSurfaceDataRow), [](const void* ptr, hash_type seed)->hash_type{ return !ptr ? 0 : qHash(*reinterpret_cast<const QtDataVisualization::QSurfaceDataRow*>(ptr), seed); }); }

void registerHashFunction_QScatterDataArray(){ ::registerHashFunction(typeid(QtDataVisualization::QScatterDataArray), [](const void* ptr, hash_type seed)->hash_type{ return !ptr ? 0 : qHash(*reinterpret_cast<const QtDataVisualization::QScatterDataArray*>(ptr), seed); }); }

#endif
