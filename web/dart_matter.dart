library dart_matter;

//dart SDK files
import 'dart:html';
import 'dart:web_gl' as webgl;
import 'dart:math' as math;

import 'land_tile.dart';

import 'package:vector_math/vector_math.dart';

import 'camera.dart' as cam;

class dart_matter {
  int area = 10;
  int quality = 11;
  int gridSize;
  double ratio;
  int baseSystemSize = 129;
  List locXY = [2.5, 2.5];
  List oldLocXY = [2.5, 2.5];
  int queueState = 0;

  int containerSize;

  land_tile baseTile = new land_tile();

  List container;

  webgl.RenderingContext gl;
  CanvasElement canvas;

  double coreTile;
  double secondTile;
  double lastTile;

  Matrix4 projectionMat;
  var camera;
  
  Vector3 oldPlayerPos = new Vector3.zero(); 
  Vector3 playerPos = new Vector3.zero();

  dart_matter(webgl.RenderingContext givenGL, CanvasElement givenCanvas) {
    gl = givenGL;
    canvas = givenCanvas;

    camera = new cam.camera(canvas);

    projectionMat =
        makePerspectiveMatrix(45, (canvas.width / canvas.height), 1, 10000);
    setPerspectiveMatrix(
        projectionMat, 45, (canvas.width / canvas.height), 1.0, 10000.0);

    gl.clearColor(1.0, 1.0, 1.0, 1.0);
    gl.clearDepth(1.0);
    gl.enable(webgl.RenderingContext.DEPTH_TEST);
  }

  draw() {
    Matrix4 viewMat = camera.getViewMat();

    gl.clear(webgl.RenderingContext.COLOR_BUFFER_BIT |
        webgl.RenderingContext.DEPTH_BUFFER_BIT);

    for (int i = 0; i < container.length; i++) {
      for (int j = 0; j < container[i].length; j++) {
        if (container[i][j] != null) {
          container[i][j].draw(viewMat, projectionMat);
        }
      }
    }
    //container[3][3].draw(viewMat, projectionMat);
  }

  update() {
    //aunto config runtime aspect runs here
    camera.update();

    //if movement over the center tile has changed, then update the center
    //store player position
    playerPos = camera.getCurrentXY();
    double posx = playerPos[0] - oldPlayerPos[0];
    double posy = playerPos[2] - oldPlayerPos[2];
    if(posx.abs() + posy.abs() > 129){//we have moved from the center
      
      if(posx.abs() > 129){
        print("x");
        if((playerPos[0] - oldPlayerPos[0]) > 129){
          locXY[0]--;
          print("-");
          oldPlayerPos[0] = playerPos[0];
        }else if((playerPos[0] - oldPlayerPos[0]) < -129){
          locXY[0]++;
          print("+");
          oldPlayerPos[0] = playerPos[0];
        }
      }
      
      if(posy.abs() > 129){
        print("y");
        if((playerPos[2] - oldPlayerPos[2]) > 129){
          locXY[1]--;
          print("-");
          oldPlayerPos[2] = playerPos[2];
        }else if((playerPos[2] - oldPlayerPos[2]) < -129){
          locXY[1]++;
          print("+");
          oldPlayerPos[2] = playerPos[2];
        }
      }
      
    }
    
    
    
    switch (queueState) {
      case 1: //center has changed, and outside tiles need to be updated
        queueState = 2;
        //remove tiles that are now out of range
        for (int i = 0; i < container.length; i++) {
          for (int j = 0; j < container[i].length; j++) {
            //find how far away a tile is
            double difI = i - locXY[0];
            double difJ = j - locXY[1];

            difI = difI.abs();
            difJ = difJ.abs();

            if (difI + difJ > lastTile) {
              container[i][j] = null;
            }
          }
        }
        print("Delete");
        print("new: $locXY");
        print("old: $oldLocXY");
        break;
      case 2: //old tiles have been removed, now add new tiles
        queueState = 3;
        for (int i = 0; i < container.length; i++) {
          for (int j = 0; j < container[i].length; j++) {
            //find how far away a tile is
            double difI = i - locXY[0];
            double difJ = j - locXY[1];

            difI = difI.abs();
            difJ = difJ.abs();

            if ((difI + difJ <= lastTile) && container[i][j] == null) {
              container[i][j] = new land_tile();
              container[i][j].generate(i, j, 33, gl);
              container[i][j].CreateHeightMap(container);
              container[i][j].CreateObject(container);
            }
          }
        }
        print("Add");
        print("new: $locXY");
        print("old: $oldLocXY");
        break;
      case 3: //old tiles have been removed, new tiles have been added, now to downgrade older tiles
        queueState = 4;
        for (int i = 0; i < container.length; i++) {
          for (int j = 0; j < container[i].length; j++) {
            //find how far away a tile is
            double difI = i - locXY[0];
            double difJ = j - locXY[1];

            difI = difI.abs();
            difJ = difJ.abs();
            //select only tiles within the secont tile range
            if ((difI + difJ <= secondTile) && (difI + difJ > coreTile)) {

              //downgrade tiles which are to high a resolution
              if (container[i][j].res == 129) {
                container[i][j].downGrade(container);
              } else if (container[i][j].res == 33) {
                //upgrade the tiles which have moved into the second range
                container[i][j].upGrade(container);
              }
            } else if ((difI + difJ <= lastTile) &&
                (difI + difJ >= secondTile)) {
              if (container[i][j].res == 65) {
                container[i][j].downGrade(container);
              }
            }
          }
        }
        print("downgrade");
        print("new: $locXY");
        print("old: $oldLocXY");
        break;
      case 4:
        queueState = 5;
        for (int i = 0; i < container.length; i++) {
          for (int j = 0; j < container[i].length; j++) {
            //find how far away a tile is
            double difI = i - locXY[0];
            double difJ = j - locXY[1];

            difI = difI.abs();
            difJ = difJ.abs();
            //select only tiles within the core tile range
            if (difI + difJ <= coreTile) {
              if (container[i][j].res == 65) {
                container[i][j].upGrade(container);
              }
            }
          }
        }
        print("downgrade");
        print("new: $locXY");
        print("old: $oldLocXY");
        break;
      case 5:
        queueState = 0;
        for (int i = 0; i < container.length; i++) {
          for (int j = 0; j < container[i].length; j++) {
            if (container[i][j] != null) {
              if (container[i][j].res == (33)) {
                container[i][j].CreateObject(container);
              }
            }
          }
        }

        for (int i = 0; i < container.length; i++) {
          for (int j = 0; j < container[i].length; j++) {
            if (container[i][j] != null) {
              if (container[i][j].res == (65)) {
                container[i][j].CreateObject(container);
              }
            }
          }
        }
        for (int i = 0; i < container.length; i++) {
          for (int j = 0; j < container[i].length; j++) {
            if (container[i][j] != null) {
              if (container[i][j].res == 129) {
                container[i][j].CreateObject(container);
              }
            }
          }
        }
        print("reset");
    }

    if ((locXY[0] != oldLocXY[0] || locXY[1] != oldLocXY[1]) &&
        queueState == 0) {
      queueState = 1;
      oldLocXY[0] = locXY[0];
      oldLocXY[1] = locXY[1];
    }

/*
 * first remove all tiles out of range
 * then add new tiles
 * then downgrade ratio 2 tiles
 * then upgrade new ratio 2 tiles
 * then downgrade old ratio 1 tiles
 * then upgrade new ratio 1 tiles
 *
 * 
 */

  }

  initState() {
    ratio = quality / (area + quality);
    print("Ratio is : $ratio");
    if (ratio >= 0.5) {
      baseSystemSize = 129;
    } else if (ratio > 0.25) {
      baseSystemSize = 65;
    } else {
      baseSystemSize = 33;
    }

    //auto config creation aspect runs here
    baseTile.generate(0, 0, baseSystemSize, gl); //start location of base tile

    container = new List();
    container.add(new List<land_tile>());
    container[0].add(baseTile);

    baseTile.CreateHeightMap(container);
    baseTile.CreateObject(container);

    print(baseTile.genTime);
    print(baseTile.runTime);

    int genTime = baseTile.genTime + baseTile.runTime;

    gridSize = (1000 / genTime).round();

    print("base system size: $baseSystemSize");
    print("grid size is: $gridSize");

    baseTile = null;
  }

  setup() {
    print("setup");
    initState();

    container = new List();

    //based on the base system size, create defult grid

    //gridSize = 40;
    if (gridSize < 12) {
      containerSize = 4;
    } else if (gridSize < 24) {
      containerSize = 6;
    } else if (gridSize < 40) {
      containerSize = 8;
    } else if (gridSize < 80) {
      containerSize = 10;
    } else {
      containerSize = 12;
    }

    /*
    if (baseSystemSize == 129) {
      containerSize = 7;
    } else if (baseSystemSize == 65) {
      containerSize = 5;
    } else {
      containerSize = 3;
    }
    */

    double layout = containerSize * ratio;

    for (int i = 0; i < 100; i++) {
      container.add(new List<land_tile>());
      for (int j = 0; j < 100; j++) {
        container[i].add(null);
      }
    }
    //baseTile = new land_tile();
    //baseTile.generate((containerSize - 1) ~/ 2, (containerSize - 1) ~/ 2, 1/*baseSystemSize*/, gl);
    //container[(containerSize - 1) ~/ 2][(containerSize - 1) ~/ 2] = baseTile;
    //print(container[1][1]);
    coreTile = layout / ((containerSize) / 2);
    secondTile = layout / ((containerSize) / 4);
    lastTile = layout / ((containerSize) / 6);

    //coreTile = 50.5;
    //secondTile = 51.5;
    //lastTile = 52.5;

    print("  coreTile: $coreTile");
    print("secondTile: $secondTile");
    print("  lastTile: $lastTile");

    double center = (containerSize - 1) / 2;
    print("Center: $center");
    for (int i = 0; i < container.length; i++) {
      for (int j = 0; j < container[i].length; j++) {
        double difI = i - center;
        double difJ = j - center;

        difI = difI.abs();
        difJ = difJ.abs();

        //print("Dif I : $difI");
        //print("Dif J : $difJ");

        if (difI + difJ <= coreTile) {
          container[i][j] = new land_tile();
          container[i][j].generate(i, j, baseSystemSize, gl);
        } else if (difI + difJ <= secondTile ||
            (((difI <= coreTile + 0.5) && (difJ <= coreTile + 0.5)) &&
                containerSize != 4)) {
          container[i][j] = new land_tile();
          int tBaseSystemSize = ((baseSystemSize + 1) ~/ 2) < 33
              ? 33
              : ((baseSystemSize + 1) ~/ 2);
          container[i][j].generate(i, j, tBaseSystemSize, gl);
        } else if ((difI + difJ <= lastTile) && containerSize != 4) {
          container[i][j] = new land_tile();
          int tBaseSystemSize = (((baseSystemSize) ~/ 4) + 1) < 33
              ? 33
              : (((baseSystemSize) ~/ 4) + 1);
          container[i][j].generate(i, j, tBaseSystemSize, gl);
        }

        /*else if ((difI + difJ <= 2) || (difI == 1.5) && (difJ == 1.5) || difI + difJ <= (containerSize) / 4) {
          container[i][j] = new land_tile();
          container[i][j].generate(i, j, 2/*((baseSystemSize + 1) ~/ 2)*/, gl);
        } else if ((difI + difJ <= (containerSize) / 2)) {
          container[i][j] = new land_tile();
          container[i][j].generate(i, j, 3/*(((baseSystemSize) ~/ 4) + 1)*/, gl);
        }*/
      }
    }

    List temptwo;
    temptwo = new List();
    for (int i = 0; i < 100; i++) {
      temptwo.add(new List());
      for (int j = 0; j < 100; j++) {
        temptwo[i].add(0);
      }
    }

    for (int i = 0; i < container.length; i++) {
      for (int j = 0; j < container[i].length; j++) {
        if (container[i][j] != null) {
          temptwo[i][j] = container[i][j].res;
        }
      }
    }

    for (int i = 0; i < containerSize; i++) {
      //print(temptwo[i]);
    }

    // *
    //* code to add a new tile to the grid and container
    /*List tempnew = new List<land_tile>();
    tempnew.add(new land_tile());
    tempnew[0].generate(1, 1, 9, gl);
    print(tempnew[0].res);
    */

/*    container[1].add(null);
    container[1][container[1].length-1] = new land_tile();
    container[1][container[1].length-1].generate(1, container[1].length, 3, gl); 
    
    print(container[1][container[1].length-1].res);*/
    //*/
    //base system has been created and is stored within the "container" class.
    //tempnew is a test to find what values are stored within the grid, and the current resolution of each tile

    //now to create the tiles
    //create the tiles with the lowest resolution first
    for (int i = 0; i < container.length; i++) {
      for (int j = 0; j < container[i].length; j++) {
        if (container[i][j] != null) {
          if (container[i][j].res == ((baseSystemSize) ~/ 4) + 1) {
            container[i][j].CreateHeightMap(container);
          }
        }
      }
    }

    for (int i = 0; i < container.length; i++) {
      for (int j = 0; j < container[i].length; j++) {
        if (container[i][j] != null) {
          if (container[i][j].res == (baseSystemSize + 1) ~/ 2) {
            container[i][j].CreateHeightMap(container);
          }
        }
      }
    }
    for (int i = 0; i < container.length; i++) {
      for (int j = 0; j < container[i].length; j++) {
        if (container[i][j] != null) {
          if (container[i][j].res == baseSystemSize) {
            container[i][j].CreateHeightMap(container);
          }
        }
      }
    }
    for (int i = 0; i < container.length; i++) {
      for (int j = 0; j < container[i].length; j++) {
        if (container[i][j] != null) {
          if (container[i][j].res == ((baseSystemSize) ~/ 4) + 1) {
            container[i][j].CreateObject(container);
          }
        }
      }
    }

    for (int i = 0; i < container.length; i++) {
      for (int j = 0; j < container[i].length; j++) {
        if (container[i][j] != null) {
          if (container[i][j].res == (baseSystemSize + 1) ~/ 2) {
            container[i][j].CreateObject(container);
          }
        }
      }
    }
    for (int i = 0; i < container.length; i++) {
      for (int j = 0; j < container[i].length; j++) {
        if (container[i][j] != null) {
          if (container[i][j].res == baseSystemSize) {
            container[i][j].CreateObject(container);
          }
        }
      }
    }
  }

  keyDown(KeyboardEvent e) {
    //hit "space" to update the water sim one time step
    if (e.keyCode == 32) {
      locXY[0] += 1.0;
      //locXY[0] += 1.0;
    }
    //hit "shift" to make the simulation run automatically, or off
    //print(e.keyCode);
    if (e.keyCode == 16) {
      locXY[0] -= 1.0;
      //locXY[0] -= 1.0;
    }
    //print(e.keyCode);

    if (e.keyCode == 17) {
      //control
      print("new: $locXY");
      print("old: $oldLocXY");
    }
    if (e.keyCode == 220) {
      // "\"
      List temptwo;
      temptwo = new List();
      for (int i = 0; i < container.length; i++) {
        temptwo.add(new List());
        for (int j = 0; j < container[i].length; j++) {
          temptwo[i].add(0);
        }
      }

      for (int i = 0; i < container.length; i++) {
        for (int j = 0; j < container[i].length; j++) {
          if (container[i][j] != null) {
            if (container[i][j].res == 129) {
              temptwo[i][j] = 1;
            }
            if (container[i][j].res == 65) {
              temptwo[i][j] = 2;
            }
            if (container[i][j].res == 33) {
              temptwo[i][j] = 3;
            }
          }
        }
      }

      for (int i = 0; i < 10; i++) {
        print(temptwo[i]);
      }
    }
  }
}
