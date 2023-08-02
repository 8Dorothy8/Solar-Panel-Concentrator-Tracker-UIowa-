greatest_eff = 0;
greatest_eff_sides = 0;
greatest_eff_conc = 0;
lowest_eff = 100;
lowest_eff_sides = 0;
lowest_eff_conc = 0;

greatest_effs = [];
temp_greatest_eff = 0;
temp_greatest_eff_conc = 0;
temp_greatest_eff_side = 0;

lowest_effs = [];
temp_lowest_eff = 100;
temp_lowest_eff_conc = 0;
temp_lowest_eff_side = 0;

sides_conc_eff = [];
% zeros(256,30);

for j = [3:12 256]
    temp_greatest_eff = 0;
    temp_lowest_eff = 100;
    for k = 2:30
        g_top_aperture_radius = (10 * sqrt(k));
        g_num_sides = j; % top 3 variables from OpenSCAD file
        g_bottom_aperture_radius = 10;
        % multiplier_ratio = 32465.0 / 544; % converts fom MATLAB units to lux
        baseline_wm2 = 544;
        % baseline: 32465 lux or 256 w/m2
        illuminance = hdrread("all/scad-" + j + "-sides-" + k + "-power.stl.obj-tmp/pmap_illuminance.hdr"); % read in illuminance image
        luminance = hdrread("all/scad-" + j + "-sides-" + k + "-power.stl.obj-tmp/pmap_luminance_nonreflective.hdr"); % read in luminance image
        bw_lum = luminance(:, :, 1); % 'greyscale' luminance image
        lum_zero_indicies = find(bw_lum == 0); % find all 0 values
        [zrow, zcol] = ind2sub(size(bw_lum), lum_zero_indicies); % create a list of rows and columns for every 0 value
        redlum = luminance; % make copy of luminance image
        % create variables for totals
        asum = 0;
        rsum = 0;
        gsum = 0;
        bsum = 0;
        num = 0;
        % loop through the list of completely black pixels, making a red pixel in
        % the copy of the luminance image and adding up all of the values of the
        % illuminance image
        for i = 1:numel(zrow)
            redlum(zrow(i), zcol(i), :) = [1, 0, 0];
            val = illuminance(zrow(i), zcol(i), :);
            asum = asum + val(1) + val(2) + val(3);
            rsum = rsum + val(1);
            gsum = gsum + val(2);
            bsum = bsum + val(3);
            num = num + 1;
        end
        % calculate areas of the input and output apertures
        taa = calculateInscribedPolygonArea(g_num_sides, g_top_aperture_radius);
        baa = calculateInscribedPolygonArea(g_num_sides, g_bottom_aperture_radius);
        efficiency = (((asum / num)/baseline_wm2)/(taa/baa))*100;
        if j == 256
            sides_conc_eff(13,k) = efficiency;
        else
            sides_conc_eff(j,k) = efficiency;
        end
        % Print everything
        %disp("Top aperture area: " + taa);
        %disp("Bottom aperture area: " + baa);
        %disp("Concentration factor: " + taa/baa);
        %disp("Average output illuminance (within bottom aperture): " + (asum / num) * multiplier_ratio * .0083 + " w/m2");
        %disp("" + ((asum / num) * multiplier_ratio * .0083)/baseline_lux + "X baseline --> " + ((((asum / num) * multiplier_ratio * .0083)/baseline_lux)/(taa/baa))*100 + "% concentrating efficiency");
        %disp("avg R: " + (rsum / num) * multiplier_ratio * .0083 + " w/m2, G: " + (gsum / num) * multiplier_ratio * .0083 + " w/m2, B: " + (bsum / num) * multiplier_ratio * .0083 + " w/m2");
        
        if efficiency > greatest_eff
            greatest_eff = efficiency;
            greatest_eff_sides = j;
            greatest_eff_conc = k;
        end
        if efficiency < lowest_eff
            lowest_eff = efficiency;
            lowest_eff_sides = j;
            lowest_eff_conc = k;
        end

        if efficiency > temp_greatest_eff
            temp_greatest_eff = efficiency;
            temp_greatest_eff_side = j;
            temp_greatest_eff_conc = k;
        end

        if efficiency < temp_lowest_eff
            temp_lowest_eff = efficiency;
            temp_lowest_eff_side = j;
            temp_lowest_eff_conc = k;
        end
        disp(k + "X " + j + "-sided concentrator with " + efficiency + "% concentrating efficiency");
    end
    greatest_effs = [greatest_effs; temp_greatest_eff, temp_greatest_eff_side, temp_greatest_eff_conc];
    lowest_effs = [lowest_effs; temp_lowest_eff, temp_lowest_eff_side, temp_lowest_eff_conc];
end
for m = 1:size(greatest_effs, 1)
    % disp("Greatest efficiency for " + greatest_effs(m, 2) + "-sided concentrators is the " + greatest_effs(m,3) + "X concentrator with " + greatest_effs(m,1) + "%");
end
for m = 1:size(lowest_effs, 1)
    % disp("Lowest efficiency for " + lowest_effs(m, 2) + "-sided concentrators is the " + lowest_effs(m,3) + "X concentrator with " + lowest_effs(m,1) + "%");
end
disp("Greatest efficiency is " + greatest_eff + "% for " + greatest_eff_conc + "X " + greatest_eff_sides + "-sided concentrator");
disp("Lowest efficiency is " + lowest_eff + "% for " + lowest_eff_conc + "X " + lowest_eff_sides + "-sided concentrator");
figure('Name','Radiance Ray Tracing 256-Sided','NumberTitle','off');
surf(sides_conc_eff);
title("Radiance Ray-Tracing Results (With 256-Sided)");
xlabel('Concentration Ratio');
ylabel('# Sides');
zlabel('Concentration Efficiency %');

% figure('Name','Radiance Ray Tracing Non-256-Sided','NumberTitle','off');
% surf(sides_conc_eff(1:12,:));
% title("Radiance Ray-Tracing Results (Without 256-Sided)");
% xlabel('Concentration Ratio');
% ylabel('# Sides');
% zlabel('Concentration Efficiency %');
function area = calculateInscribedPolygonArea(numSides, radius)
 % Calculate the area of an inscribed polygon
 apothem = radius * cos(pi / numSides);
 sideLength = 2 * radius * sin(pi / numSides);
 area = 0.5 * numSides * sideLength * apothem;
 
 % Print the area
 % fprintf('The area of the inscribed polygon is: %.2f\n', area);
end