import 'dart:html';
import 'dart:async';
import 'dart:web_gl' as webgl;

import 'dart:isolate';

import 'dart_matter.dart';

void main() {
  //Select the canvas as our rneder tatget
  CanvasElement canvas = querySelector("#render-target"); 
  //canvas.requestFullscreen();
  print("hi");
  webgl.RenderingContext gl = canvas.getContext3d();
  
  var nexus = new dart_matter(gl, canvas);
  
  //set up the enviroment
  nexus.setup();
  
  logic(){
     
    new Future.delayed(const Duration(milliseconds: 15), logic);
    nexus.update();
      
  }
  
  camera(){
    //new Future.delayed(const Duration(milliseconds: 15), logic);
    //nexus.camera.update();
  }
  render(time){
    window.requestAnimationFrame(render);
    nexus.draw(); 
  }

  camera();
  logic();
  render(1);
  
  window.onKeyDown.listen(nexus.keyDown);


}

