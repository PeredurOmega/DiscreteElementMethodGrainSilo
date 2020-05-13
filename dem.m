clear all;
close all;

%Définition de la constante de raideur des parois du silo
stiffness_silo = 100;

%Définition de la constante de raideur des grains
stiffness_grain = 10;

%Définition de la pesanteur
g=9.81;

%Hauteur de la partie verticale du silo
vertical_silo_height=5/5;

%Rayon du silo (partie verticale)
vertical_silo_radius=2/5;

%Rayon du silo (partie écoulement)
flow_silo_radius=0.1/5;

%Angle entre la partie oblique par rapport au sol (axe y=0)
alpha=pi/4;

%Nous considérons que le centre du silo se situe à x=0 et que à y=0 se
%trouve la sortie du silo (partie où l'on mesure le débit d'écoulement)

%Ainsi la paroi oblique droite va de Rse à Rsv en x et de 0 à
%(Rsv-Rse)/cos(alpha) en y. Et la paroi de gauche va de -Rse à -Rsv en x
%et de 0 à (Rse-Rsv)/cos(alpha) en y
y_right = @(x) (x-flow_silo_radius)*tan(alpha);
y_left = @(x) (-x-flow_silo_radius)*tan(alpha);
x_diff = @(y_diff) y_diff/tan(alpha);

%Hauteur de la paroi oblique
flow_silo_height=y_right(vertical_silo_radius);

%Rayon d'un grain de blé sur le dessin
global draw_factor
draw_factor=15/(0.006);

%Définition du pas de temps
global dt
dt=0.01;

%Définition de la durée de la simulation
t_end=10;

%Définition du nombre d'itérations nécessaires sur le temps
t_count=t_end/dt;

%Définition du nombre de grains
grain_count=200;

%Définition de la période de mise à jour des voisinages
update_period=10;

%Définition du "rayon de voisinage"
r_vicinity=0.5*g*(update_period*dt)^2;

%Définition du nombre maximum de voisins
neighboors_count=10;

%Initialisation de la matrice des voisins
%-1 signifie qu'il n'y a pas de voisins
neighboors=-1.*ones(1,neighboors_count,grain_count);

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
axis equal

% Définition de l'état initial des grains et dessin de leur état à
% l'initialisation
grains(grain_count)=Grain;

%Génération des tailles des grains selon une distribution normale
random_size = randn(1, grain_count);

%Génération des masses par une distribution normale
masses=0.005+random_size.*0.001;

%Génération des rayons par une distribution normale
radii=0.006+random_size.*0.001;

for i=1:1:grain_count
    %Créer un grain avec x aléatoire entre le rayon du silo et moins le 
    %rayon du silo ety aléatoire entre 0 et la hauteur du silo
    grains(i)=init(grains(i),(rand-0.5).*(2*vertical_silo_radius), (rand.*vertical_silo_height)+flow_silo_height, masses(i), radii(i));
    %Dessin du grain i
    grains(i)=draw(grains(i));
end

%Supression des variables inutiles
clear masses;
clear radii;
clear random_size;

%Boucle principale en fonction du temps
for t=2:1:t_count
    %Boucle sur tous les grains
    for i=1:1:grain_count
        %Calcul de la nouvelle position et de la nouvelle vitesse du grain
        %i
        grains(i)=compute_position_and_speed(grains(i));
    end
    
    %Boucle sur tous les grains
    for i=1:1:grain_count
        %Coordonnées du grain i
        x_grain_i=grains(i).position.x;
        y_grain_i=grains(i).position.y;
        r_grain=grains(i).radius;
        
        if y_grain_i < -0.5
           continue 
        end
        
        %Mise à jour des voisinages
        if update_period==t || t==1
            %Réinitialisation des voisinages pour le grain i
            neighboors(:,:,i)=-1.*ones(1,neighboors_count);
            
            %Initialisation du compteur de voisins de i
            neighboors_i_count=0;
            
            %Ajout des voisins
            j = 1;
            while j<=grain_count && neighboors_i_count < neighboors_count
                %Coordonnées du grain j
                x_grain_j=grains(j).position.x;
                y_grain_j=grains(j).position.y;
                
                if j==i || y_grain_j < -0.5
                    %Incrémentation du compteur
                    j=j+1;
                    continue;
                end
                
                %Vérification du voisinage
                if (abs(x_grain_j-x_grain_i) <= r_vicinity || abs(y_grain_j-y_grain_i) <= r_vicinity)
                    %Ajout en tant que voisin
                    neighboors(:,neighboors_i_count+1,i)=j;
                    
                    %Incrémentation du nombre de voisins
                    neighboors_i_count=neighboors_i_count+1;
                end
                
                %Incrémentation du compteur
                j=j+1;
            end
        end
        
        %Application des efforts à distance (la pesanteur...TODO)
        force_i=Pair(0,-grains(i).mass*g);
        
        %Boucle sur tous les grains appartenant à la liste des voisins de i
        k=1;
        while 1
            %Initialisation du voisin k
            neighboor=neighboors(k);
            
            %Si il n'y a pas de voisin à la position k -> arrêt de la
            %boucle
            if neighboor == -1
                break;
            end
            
            %Coordonnées du grain j (voisin / neighboor)
            x_grain_j=grains(neighboor).position.x;
            y_grain_j=grains(neighboor).position.y;
            
            %Calcul de la différence de distance entre les voisins
            diff_x=x_grain_i-x_grain_j;
            diff_y=y_grain_i-y_grain_j;
            
            %Application des forces de contacts en x sur i
            if abs(diff_x) < r_grain
                if diff_x < 0
                    force_i.x=force_i.x+stiffness_grain*diff_x;
                else
                    force_i.x=force_i.x+stiffness_grain*diff_x;
                end
            end  
            
            %Application des forces de contacts en y sur i
            if abs(diff_y) < r_grain
                if diff_y < 0
                    force_i.y=force_i.y+stiffness_grain*diff_y;
                else
                    force_i.y=force_i.y+stiffness_grain*diff_y;
                end
            end
            
            %Incrémentation de la boucle
            k=k+1;
            
            %Si tous les voisins ont été contrôlés -> arrêt de la boucle
            if k>neighboors_count
                break;
            end
        end
        
        %Détermination des contacts avec la paroi du silo
        if y_grain_i > 0
            if x_grain_i >= flow_silo_radius && y_right(x_grain_i) >= y_grain_i
                %Contact paroi droite
                diff_y=y_right(x_grain_i)-y_grain_i;
                force_i.x=force_i.x-x_diff(diff_y)*stiffness_silo;
                %force_i.y=force_i.y+diff_y*stiffness_silo;
            elseif x_grain_i <= -flow_silo_radius && y_left(x_grain_i) >= y_grain_i
                %Contact paroi gauche
                diff_y=y_left(x_grain_i)-y_grain_i;
                force_i.x=force_i.x+x_diff(diff_y)*stiffness_silo;
                %force_i.y=force_i.y+diff_y*stiffness_silo;
            elseif x_grain_i > vertical_silo_radius
                %Contact paroi verticale droite
                force_i.x=force_i.x+(vertical_silo_radius-x_grain_i)*stiffness_silo;
            elseif x_grain_i < -vertical_silo_radius
                %Contact paroi verticale gauche
                force_i.x=force_i.x+(-x_grain_i-vertical_silo_radius)*stiffness_silo;
            end
        end
        
        %Calcul de la position du grain
        grains(i)=compute_acceleration_and_half_time_speed(grains(i), force_i);
        
        %Dessin du grain i
        grains(i)=draw(grains(i));
    end
    
    %Dessin de cet instant t
    drawnow
end