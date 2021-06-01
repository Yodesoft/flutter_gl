
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

import 'opengl/OpenGLContextES.dart' if (dart.library.js) 'opengl/OpenGLContextWeb.dart';

import 'OpenGL-Base.dart';
import 'opengl/opengl_es_bindings/opengl_es_bindings.dart';


getInstance(Map<String, dynamic> options) {
  return OpenGLES(options);
}

class OpenGLES extends OpenGLBase {
  int _display = 0;
  int _surface = 0;
  int _context = 0;

  late int width;
  late int height;
  num dpr = 1.0;

  Pointer<Uint32> frameBuffer =  malloc.allocate<Uint32>(sizeOf<Uint32>() * 1);
  Pointer<Uint32> frameBufferTexture =  malloc.allocate<Uint32>(sizeOf<Uint32>() * 1);
  Pointer<Uint32> renderBuffer =  malloc.allocate<Uint32>(sizeOf<Uint32>() * 1);

  int get defaultFrameBuffer => frameBuffer.value;
  int get defaultTexture => frameBufferTexture.value;


  late LibOpenGLES _libOpenGLES;
  late LibEGL _libEGL;
  dynamic? _gl;

  dynamic get gl {
    _gl ??= getContext({"gl": _libOpenGLES});
    return _gl;
  }

  LibEGL get egl => _libEGL;

  OpenGLES(Map<String, dynamic> options) : super(options) {
    final DynamicLibrary? libEGL = getEglLibrary();
    final DynamicLibrary? libGLESv3 = getGLLibrary();

    _libOpenGLES = LibOpenGLES(libGLESv3!);
    _libEGL = LibEGL(libEGL!);

    this.width = options["width"];
    this.height = options["height"];
    this.dpr = options["dpr"];

    print(" init OpenGLES 123 ");
  }


  DynamicLibrary? getEglLibrary() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open("libEGL.so");
    } else {
      return DynamicLibrary.process();
    }
  }

  DynamicLibrary? getGLLibrary() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open("libGLESv3.so");
    } else {
      return DynamicLibrary.process();
    }
  }

  makeCurrent(List<int> egls) {

    if(Platform.isAndroid) {
      _display = egls[3];
      _surface = egls[4];
      _context = egls[5];
      /// bind context to this thread. All following OpenGL calls from this thread will use this context
      eglMakeCurrent(_display, _surface, _surface, _context);
    } else if(Platform.isIOS) {
      egl.makeCurrent(_context);
    }
  
  }


  eglMakeCurrent(
    int display,
    int draw,
    int read,
    int context,
  ) {

    var _v = egl.eglMakeCurrent(display, draw, read, context);

    print(" OpenGLES eglMakeCurrent _v: ${_v} ");

    final nativeCallResult = _v == 1;

    if (nativeCallResult) {
      return;
    }

    throw ('Failed to make current using display [$display], draw [$draw], read [$read], context [$context].');
  }


  dispose() {
    // 切出当前的上下文
    eglMakeCurrent(_display, 0, 0, 0);

    print(" OpenGL-ES dispose .... ");
  }

}





Pointer<Float> floatListToArrayPointer(List<double> list) {
  final ptr = calloc<Float>(list.length);
  ptr.asTypedList(list.length).setAll(0, list);
  return ptr;
}

Pointer<Int32> int32ListToArrayPointer(List<int> list) {
  final ptr = calloc<Int32>(list.length);
  ptr.asTypedList(list.length).setAll(0, list);
  return ptr;
}

Pointer<Int32> intListToArray(List<int> list) {
  final ptr = malloc.allocate<Int32>(sizeOf<Int32>() * list.length);
  for (var i = 0; i < list.length; i++) {
    ptr.elementAt(i).value = list[i];
  }
  return ptr;
}

Pointer<Uint16> uInt16ListToArrayPointer(List<int> list) {
  final ptr = calloc<Uint16>(list.length);
  ptr.asTypedList(list.length).setAll(0, list);
  return ptr;
}