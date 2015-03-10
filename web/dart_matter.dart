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
    /*if(baseTile.genTime > 1){//Temp numbers for now, just for testing
      baseTile.downSize;
      baseSystemSize = ((baseSystemSize+1)~/2);
    }*/
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
        
        if(i < ((containerSize-1)/2))
        
        
        if(i == ((containerSize-1)/2)+1 || i == ((containerSize-1)/2)-1){
          if(j == ((containerSize-1)/2)+1 || j == ((containerSize-1)/2)-1){
            container[i][j] = new land_tile();
            container[i][j].generate(i, j,2);
          }
        }
        
        
        
        
        /*
        int loc = (i+j);
        int center = containerSize;
        //print(loc - center);
        int dif = loc - center;
        if(dif.abs() < (containerSize-1/2)){
          if(dif.abs() == 1){//next to base tile, share resolution
            container[i][j] = new land_tile();
            container[i][j].generate(i, j,1);  
          }else if(dif.abs() == 2 || dif.abs() == 0){
            if(i == 3 && j == 3){
              container[i][j] = new land_tile();
              container[i][j].generate(i, j,5);
            }else if(dif.abs() == 0){
              if(i == (containerSize-1/2)+1 || i == (containerSize-1/2)-1){
                if(j == (containerSize-1/2)+1 || j == (containerSize-1/2)-1){
                  container[i][j] = new land_tile();
                  container[i][j].generate(i, j,2);
                }
              }
            }else{
              container[i][j] = new land_tile();
              container[i][j].generate(i, j,2);
            }
          }else if(dif.abs() == 3){
            int temp = (baseSystemSize+1)~/2;
            temp = (temp+1)~/2;
            container[i][j] = new land_tile();
            container[i][j].generate(i, j, 3);
          }
        }
        */
      }
    }
    int countone = 0;
    int counttwo = 0;
    int countthree = 0;
    
    List temptwo;
    temptwo = new List(10);
    for(int i = 0; i < 10; i++){
      temptwo[i] = new List(10);
      for(int j = 0; j < 10; j++){
        temptwo[i][j] = 0;
      } 
    }
    
    for(int i = 0; i < container.length; i++){
      for(int j = 0; j < container[i].length; j++){
        if(container[i][j] != null){
          temptwo[i][j] = container[i][j].res;
          //print(container[i][j].res);
          /*if(container[i][j].res == 129){
            countone++;
          }else if(container[i][j].res == 65){
            counttwo++;
          }else if(container[i][j].res == 33){
            countthree++;
          }*/
        }
      }
    }
    /*print(countone);
    print(counttwo);
    print(countthree);*/
    
    for(int i = 0; i < 10; i++){
      print(temptwo[i]);
    }
    
    
  }
  
}