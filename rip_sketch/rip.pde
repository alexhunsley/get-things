import com.krab.lazy.*;

// TODO
// [ ] put interface at top, controls at bottom, for more natural viewing
//
//

// Of note:
// The saves persist between runs of this sketch! Nice!
//

LazyGui gui;

// can paste in values from e.g. https://colorhunt.co

color default_bg_col = color(255, 255, 245);
color default_bubble_col = color(160, 210, 120);
color default_text_col = color(30, 30, 30);

float display_scale = 1.0;  

// increasing this makes the circle drift right more and more, so a /2 error somewhere?
int baseResX = 500;
int baseResY = 800;

// NOTE can't use these in settings(), as otherwise using smooth() throws an error! 
// These calcs are just inline in setup() now.
// BUT the calc there HAS to reflect this here, which is used below.
int resX = int(float(baseResX) * display_scale);
int resY = int(float(baseResY) * display_scale);

// the simulated device resolution
int renderResX = 400;
int renderResY = 400;

int bottom_border = 50;

int renderCentreX = int(float(resX) / 2);
// the render box uses the smallest of the left/right border (around render box and bottom_border
int renderCentreY = resY - renderResY/2 - min(bottom_border, (resX - renderResX) / 2);

float circleRadius = 45.0 * display_scale;
float sqrt3 = sqrt(3);

float equi_tri_x = 1.0;
float equi_tri_diag = 2.0;
float equi_tri_y = sqrt3;

float circleGap = 10.0 * display_scale;

int[] rows = {3, 4, 3, 4, 3};

float spacing = circleGap + circleRadius * 2;

float circle_block_inner_height = equi_tri_y * spacing;

// Centering the grid horizontally
//float offsetX = float(resX) / 2 - 1.5 * spacing;
float offsetX = float(renderResX) / 2 - 1.5 * spacing;

//// Centering the grid vertically
float offsetY = float(renderResY) / 2 - ((float(rows.length - 1) / 2) * circle_block_inner_height) / 2;

//println(offsetX);

// settings() is like setup but lets us use vars in the size() call
void settings() {
  // this clashes with LazyGUI? Oh, can't repro that now. Good.
  smooth(10);

  size(resX, resY, P2D);

  //noStroke();
  //smooth();

}

void setup() {
  //size(500, 800, P2D);
  //size(int(float(baseResX) * display_scale), int(float(baseResY) * display_scale), P2D);
  
  //smooth(5);

  gui = new LazyGui(this);
  

  textSize(12); // Set text size
  textAlign(CENTER, CENTER); // Set text alignment to center

  // need to loop for LazyGUI to work
  //noLoop();
  
  //translate(renderCentreX - renderResX/2, renderCentreY - renderResY/2);

}
  
void draw_device_border() {
    stroke(100);
    noFill();
    rect(0, 0, renderResX, renderResY); 

    //rect(-renderResX/2, -renderResY/2, renderResX, renderResY); 
}

void drawText(float x, float y, String s) {
    fill(default_text_col);

    noStroke(); // No outline for the text
    textAlign(CENTER, CENTER); // Set text alignment to center
    text(s, x, y); // Draw text at coordinates (200, 200)

    noFill();
    stroke(255);
}

int counter = 0;

void draw(){
    background(1);
    //print(gui.colorPicker("background").hex);
    background(gui.colorPicker("background", default_bg_col).hex);
    
    int bubble_col = gui.colorPicker("bubble col", default_bubble_col).hex;

    // all device rendering is done relative to TL of device border
    translate(renderCentreX - renderResX/2, renderCentreY - renderResY/2);

    draw_device_border();
    
    for (int yy = 0; yy < rows.length; yy++) {
      // yy relative to centre circle
      float yy_rel_centre = yy - (rows.length - 1) / 2;
      
      int numCircles = rows[yy];
  
      float y = offsetY + (float(yy) * equi_tri_y * spacing) / 2;

      // Adjusting the starting x position for rows with 3 circles
      //float startX = offsetX;
      float startX = offsetX;
      if (numCircles == 3) {
        startX += spacing / 2;
      }

      for (int xx = 0; xx < numCircles; xx++) {
        float xx_rel_centre = float(xx) - (float(numCircles - 1) / 2.0);
        
        float circle_dist_from_centre = abs(xx_rel_centre) + abs(yy_rel_centre);

        // fine-tune bubble size
        float circle_scale_factor = 1.0 - circle_dist_from_centre / 9.0;
        float circle_diam = circle_scale_factor * 2 * circleRadius;

        float x_offset_scaley = 25;
        float y_offset_scaley = 25;
  
        float x_offset_scale_factor = 1.0 - circle_dist_from_centre / x_offset_scaley;
        float y_offset_scale_factor = 1.0 - circle_dist_from_centre / y_offset_scaley;
        
        float x = startX + float(xx) * spacing; // this spacing correct?@?!
              
        // fine-tune bubble position
        float nx = renderResX / 2 + x_offset_scale_factor * (x - renderResX / 2);
        float ny = renderResY / 2 + y_offset_scale_factor * (y - renderResY / 2);
    
        //float nx = x;
        //float ny = y;
        

            
      //    drawText(nx, ny, `${x.toFixed(0)} ${y.toFixed(0)}`)
      //drawText(nx, ny + 12, `${y_offset_scale_factor.toFixed(3)}`)
      
        noStroke();
        fill(bubble_col);
        ellipse(int(nx), int(ny), circle_diam, circle_diam);

        // this func handles the styling, remember!
        drawText(nx, ny - 18, xx_rel_centre + " " + yy_rel_centre);
        drawText(nx, ny - 6, String.format("%d %d", (int) xx_rel_centre, (int) yy_rel_centre));
        drawText(nx, ny + 6, String.format("%.3f", y_offset_scale_factor));
        drawText(nx, ny + 18, int(nx) + " " + int(ny));

      }
    }
    drawText(5, 5, String.format("%d", counter));
    counter++;
    // translate(x, y)
}
