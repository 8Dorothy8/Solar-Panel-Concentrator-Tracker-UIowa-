g_concentration_ratio = 13;

// Acceptance angle overrides concentration ratio if use_acc_angle is true
g_half_acceptance_angle = 37.5096;
use_acc_angle = false;

g_bottom_aperture_radius = 10;

// Side count of the print
g_num_sides = 256;

// Thickness of the print
g_concentrator_shell_thickness = 3.2;

// Height of the print
g_height = 60;
g_top_aperture_radius = 0;

g_top_aperture_radius = use_acc_angle == false ? (g_bottom_aperture_radius * sqrt(g_concentration_ratio)) : (g_height*tan(g_half_acceptance_angle))-g_bottom_aperture_radius;

// Resolution/graininess of the print
g_reso = 0.5;
g_support_cylinder_reach = 0.56;
g_support_cylinder_cover = 0.62;

// Stand height and width
stand_height = 10;
stand_width = 50;
pi = 3.14159265;

//
// para_begin = 0;
para_begin = (g_bottom_aperture_radius*g_bottom_aperture_radius);
para_end = (g_top_aperture_radius*g_top_aperture_radius);
$fn = 128;

module print_inscribed_polygon_area(radius, sides) {
    apothem = radius * cos(180/sides);
    side_length = 2 * radius * sin(180/sides);
    area = 0.5 * sides * side_length * apothem;
    echo(area);
}
module print_concentrating_power(rad1, rad2, sides) {
    apothem1 = rad1 * cos(180/sides);
    side_length1 = 2 * rad1 * sin(180/sides);
    area1 = 0.5 * sides * side_length1 * apothem1;
    apothem2 = rad2 * cos(180/sides);
    side_length2 = 2 * rad2 * sin(180/sides);
    area2 = 0.5 * sides * side_length2 * apothem2;
    echo(area1/area2);
}

module stand() {
    translate([0, 0, stand_height / 2]) cube([stand_width, stand_width, stand_height], center=true);
   
}

// module linear_concentrator
module linear_conc_inner(height, top_aperture_radius, bottom_aperture_radius, concentrator_shell_thickness, num_sides) {
    outer_tar = top_aperture_radius + concentrator_shell_thickness;
outer_bar = bottom_aperture_radius + concentrator_shell_thickness;
    //difference() {
        //linear_extrude(height = height, center = true, convexity = 10, scale = (outer_tar/outer_bar)) circle(r=outer_bar, $fn=num_sides);
    linear_extrude(height = height, center = true, convexity = 10, scale = (top_aperture_radius/bottom_aperture_radius)) circle(r=bottom_aperture_radius, $fn=num_sides);
    //}
}
module linear_conc_outer(height, top_aperture_radius, bottom_aperture_radius, concentrator_shell_thickness, num_sides) {
    outer_tar = top_aperture_radius + concentrator_shell_thickness;
outer_bar = bottom_aperture_radius + concentrator_shell_thickness;
    //difference() {
        linear_extrude(height = height, center = true, convexity = 10, scale = (outer_tar/outer_bar)) circle(r=outer_bar, $fn=num_sides);
    //linear_extrude(height = height, center = true, convexity = 10, scale = (top_aperture_radius/bottom_aperture_radius)) circle(r=bottom_aperture_radius, $fn=num_sides);
    //}
}
module inner_concentrator() {
union() {
// Iterate through height of concentrator at g_reso increments
for ( i = [0 : g_reso : g_height] ) {
    current_progress = i / g_height;
    last_progress = (i - g_reso) / g_height;
    calculated_x_value = (current_progress * (para_end - para_begin)) + para_begin;
    prev_calculated_x_value = ((last_progress) * (para_end - para_begin)) + para_begin;
    calculated_current_size = sqrt(calculated_x_value);
    prev_calculated_current_size = sqrt(prev_calculated_x_value);
    //echo(calculated_current_size);
    //echo(prev_calculated_current_size);
    // echo(tempconst);
    translate([0, 0, i]) linear_conc_inner(g_reso, calculated_current_size, prev_calculated_current_size, 2, g_num_sides);
}
}
}
module outer_concentrator() {
union() {
for ( i = [0 : g_reso : g_height] ) {
    current_progress = i / g_height;
    last_progress = (i - g_reso) / g_height;
    calculated_x_value = (current_progress * (para_end - para_begin)) + para_begin;
    prev_calculated_x_value = ((last_progress) * (para_end - para_begin)) + para_begin;
    calculated_current_size = sqrt(calculated_x_value);
    prev_calculated_current_size = sqrt(prev_calculated_x_value);
    //echo(calculated_current_size);
    //echo(prev_calculated_current_size);
    // echo(tempconst);
    translate([0, 0, i]) linear_conc_outer(g_reso, calculated_current_size, prev_calculated_current_size, 2, g_num_sides);
}
}
}
module full_concentrator() {
    difference() {
        union() {
            outer_concentrator();
            stand();
            translate([0, 0, stand_height]) cylinder(h = g_height * g_support_cylinder_reach, r1 = (stand_width/2) * g_support_cylinder_cover, r2 = 1, center=false);
        }
        union() {
            inner_concentrator();
            translate([0, 0, -400]) cube([800, 800, 800], center = true);
        }
    }
}
full_concentrator();
echo("Bottom aperture area:");
print_inscribed_polygon_area(g_bottom_aperture_radius, g_num_sides);
echo("Top aperture area:");
print_inscribed_polygon_area(g_top_aperture_radius, g_num_sides);
echo("Concentrating power:");
print_concentrating_power(g_top_aperture_radius, g_bottom_aperture_radius, g_num_sides);
echo("Acceptance angle:");
echo(atan((g_bottom_aperture_radius+g_top_aperture_radius)/g_height));
echo("Parabola sides defined by function y = kx^2. k:");
echo(g_height/((g_top_aperture_radius*g_top_aperture_radius)-(g_bottom_aperture_radius*g_bottom_aperture_radius)));
// linear_conc_slot(5, 20, 10, 2, 5);