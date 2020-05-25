function [] = draw_silo(y_left,y_right,vertical_silo_radius,flow_silo_radius,vertical_silo_height)
%DRAW_SILO Draw the shape of the silo
%Dessin du silo
fplot(y_left, [-vertical_silo_radius -flow_silo_radius],'Color','red');
hold on
fplot(y_right, [flow_silo_radius vertical_silo_radius],'Color','red');
hold on
line([vertical_silo_radius vertical_silo_radius], [y_right(vertical_silo_radius) y_right(vertical_silo_radius)+vertical_silo_height],'Color','red')
hold on
line([-vertical_silo_radius -vertical_silo_radius], [y_left(-vertical_silo_radius) y_left(-vertical_silo_radius)+vertical_silo_height],'Color','red')
hold on
grid
axis([-vertical_silo_radius-0.01 vertical_silo_radius+0.01 -0.05 vertical_silo_height+0.1])
end

