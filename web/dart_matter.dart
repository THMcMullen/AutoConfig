library dart_matter;

//dart SDK files
import 'dart:html';
import 'dart:web_gl' as webgl;
import 'dart:math' as math;

import 'land_tile.dart';

class dart_matter{
  
  int baseSystemSize = 129;
    
  land_tile baseTile = new land_tile();
  
  List container;
  
  dart_matter(webgl.RenderingContext givenGL, CanvasElement canvas){
    
  }
  
  draw(){
    
  }
  
  update(){
    //aunto config runtime aspect runs here
  }
  
  setup(){
    print("setup");
    //auto config creation aspect runs here
    baseTile.generate(5, 5, baseSystemSize);//start location of base tile
    if(baseTile.genTime > 1){//Temp numbers for now, just for testing
      baseTile.downSize;
      baseSystemSize = ((baseSystemSize+1)~/2);
    }
    int containerSize;
    if(baseSystemSize == 129){
      containerSize = 7;
    }else if(baseSystemSize == 65){
      containerSize = 5;
    }else{
      containerSize = 3;
    }
    container = new List(containerSize);

    for(int i = 0; i < container.length; i++){
      container[i] = new List<land_tile>(containerSize);
      for(int j = 0; j < container[i].length; j++){
        container[i][j] = null;
      }
    } 
    print((containerSize-1)/2);
    for(int i = 0; i < container.length; i++){
      for(int j = 0; j < container[i].length; j++){
        
        int difI = i - (containerSize-1)~/2;
        int difJ = j - (containerSize-1)~/2;
        
        difI = difI.abs();
        difJ = difJ.abs();
        
        if(difI + difJ < (containerSize)/2){//the difference on the x and y are less than 3
          if(difI + difJ == 1){
            container[i][j] = new land_tile();
            container[i][j].generate(i, j, 1); 
          }else if(difI + difJ == 2){
            container[i][j] = new land_tile();
            container[i][j].generate(i, j, 2); 
          }else if(difI + difJ == 3){
            container[i][j] = new land_tile();
            container[i][j].generate(i, j, 3); 
          } 
        }
   
      }
    }
    
    
    List temptwo;
    temptwo = new List();
    for(int i = 0; i < containerSize; i++){
      temptwo.add(new List());
      for(int j = 0; j < containerSize; j++){
        temptwo[i].add(0);
      } 
    }
    
    for(int i = 0; i < container.length; i++){
      for(int j = 0; j < container[i].length; j++){
        if(container[i][j] != null){
          temptwo[i][j] = container[i][j].res;
        }
      }
    }
    
    for(int i = 0; i < containerSize; i++){
      print(temptwo[i]);
    }
    List tempnew = new List <land_tile>();
    tempnew.add(new land_tile());
    tempnew[0].generate(1,1,9);
    print(tempnew[0].res);

  }
  
}