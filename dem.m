clear all;
close all;

%Définition de la constante de raideur des parois du silo
stiffness_silo = 1;

%Définition de la constante de raideur des grains
stiffness_grain = 1;

%Définition de la masse d'un grain
m_grain = 0.005;

%Rayon d'un grain de blé
r_grain = 0.0006;

%Rayon d'un grain de blé sur le dessin
draw_r_grain = 15;

%Définition de la pesanteur
g=9.81;

%Hauteur de la partie verticale du silo
vertical_silo_height=5;

%Rayon du silo (partie verticale)
vertical_silo_radius=2;

%Rayon du silo (partie écoulement)
flow_silo_radius=0.1;

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

%Définition du pas de temps
dt=0.01;

%Définition de la durée de la simulation
t_end=10;
t_count=t_end/dt;

%Définition du nombre de grains
grain_count=100;

% Définition de l'état initial (position + vitesse + accélération)
pos=zeros(1,2,grain_count, t_count);
for l=1:1:grain_count
    %Position x aléatoire entre le rayon du silo et moins le rayon du silo
    pos(:,1,l,1)=(rand-0.5).*(2*vertical_silo_radius); 
    %Position y aléatoire entre 
    pos(:,2,l,1)=(rand.*vertical_silo_height)+flow_silo_height;
end
speed=zeros(1,2,grain_count, t_count);
acceleration=zeros(1,2,grain_count, t_count);
half_time_speed=zeros(1,2,grain_count);

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

%Dessin des grain à l'intitialisation
grainDrawings = zeros(1,grain_count);
%Boucle sur tous les grains
for i=1:1:grain_count
    %Coordonnées du grain i
    x_grain_i=pos(:,1,i,1);
    y_grain_i=pos(:,2,i,1);
    grainDrawings(i) = plot(x_grain_i, y_grain_i, '.', 'Markersize', draw_r_grain,'Color','blue');
end


%Boucle principale en fonction du temps
for t=2:1:t_count
    %Boucle sur tous les grains
    for i=1:1:grain_count
        %Récupération de la vitesse de demi-temps
        x_half_time_speed_i=half_time_speed(:,1,i);
        y_half_time_speed_i=half_time_speed(:,2,i);
        
        %Calcul de la nouvelle position du grain i
        pos(:,1,i,t)=pos(:,1,i,t-1)+x_half_time_speed_i*dt;
        pos(:,2,i,t)=pos(:,2,i,t-1)+y_half_time_speed_i*dt;
        
        %Calcul de la vitesse du grain i
        speed(:,1,i,t)=x_half_time_speed_i+acceleration(:,1,i,t-1)*(dt/2);
        speed(:,2,i,t)=y_half_time_speed_i+acceleration(:,2,i,t-1)*(dt/2);
    end
    
    %Boucle sur tous les grains
    for i=1:1:grain_count
        %Coordonnées du grain i
        x_grain_i=pos(:,1,i,t);
        y_grain_i=pos(:,2,i,t);
        
        if y_grain_i < -0.5
           continue 
        end
        
        %Mise à jour des voisinages
        if update_period==t || t==1
            %Réinitialisation des voisinages pour le grain i
            neighboors(:,:,i)=-1.*ones(1,neighboors_count);
            
            %Coordonnées du grain j
            x_grain_j=pos(:,1,i,t);
            y_grain_ij=pos(:,2,i,t);
            
            %Initialisation du compteur de voisins de i
            neighboors_i_count=0;
            
            %Ajout des voisins
            j = 1;
            while j<=grain_count && neighboors_i_count < neighboors_count
                if (abs(x_grain_j-x_grain_i) <= r_vicinity || abs(y_grain_j-y_grain_i) <= r_vicinity)
                    neighboors(:,neighboors_i_count+1,i)=j;
                    neighboors_i_count=neighboors_i_count+1;
                end
                j=j+1;
            end
        end
        
        %Application des efforts à distance (la pesanteur...TODO)
        force_i=[0 -m_grain*g];
        
        %Boucle sur tous les grains appartenant à la liste des voisins de i
        k=1;
        while 1
            %Initialisation du voisin k
            neighboor=neighboors(k);
            
            %Si il n'y a pas de voinsi à la position k -> arrêt de la
            %boucle
            if neighboor == -1
                break;
            end
            
            %Coordonnées du grain j (voisin / neighboor)
            x_grain_j=pos(:,1,neighboor,t);
            y_grain_j=pos(:,2,neighboor,t);
            
            %Calcul de la différence de distance entre les voisins
            diff_x=x_grain_i-x_grain_j;
            diff_y=y_grain_i-y_grain_j;
            
            %Application des forces de contacts en x sur i
            if abs(diff_x) < r_grain
                if diff_x < 0
                    force_i(2)=force_i(2)+stiffness_grain*diff_x;
                else
                    force_i(2)=force_i(2)+stiffness_grain*diff_x;
                end
            end  
            
            %Application des forces de contacts en y sur i
            if abs(diff_y) < r_grain
                if diff_y < 0
                    force_i(2)=force_i(2)+stiffness_grain*diff_y;
                else
                    force_i(2)=force_i(2)+stiffness_grain*diff_y;
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
                force_i(1)=force_i(1)-x_diff(diff_y)*stiffness_silo;
                force_i(2)=force_i(2)+diff_y*stiffness_silo;
            elseif x_grain_i <= -flow_silo_radius && y_left(x_grain_i) >= y_grain_i
                %Contact paroi gauche
                diff_y=y_left(x_grain_i)-y_grain_i;
                force_i(1)=force_i(1)+x_diff(diff_y)*stiffness_silo;
                force_i(2)=force_i(2)+diff_y*stiffness_silo;
            elseif x_grain_i > vertical_silo_radius
                %Contact paroi verticale droite
                force_i(1)=force_i(1)+(vertical_silo_radius-x_grain_i)*stiffness_silo;
            elseif x_grain_i < -vertical_silo_radius
                %Contact paroi verticale gauche
                force_i(1)=force_i(1)+(-x_grain_i-vertical_silo_radius)*stiffness_silo;
            end
        end
        
        %Calcul de l'accélération du grain i
        acceleration(:,1,i,t)=force_i(1)/m_grain ;
        acceleration(:,2,i,t)=force_i(2)/m_grain ;
        
        %Calcul de la vitesse de demi pas de temps
        half_time_speed(:,1,i)=half_time_speed(:,1,i)+acceleration(:,1,i,t)*dt;
        half_time_speed(:,2,i)=half_time_speed(:,2,i)+acceleration(:,2,i,t)*dt;
        
        %Dessin du grain i
        delete(grainDrawings(i));
        grainDrawings(i) = plot(x_grain_i, y_grain_i, '.', 'Markersize', draw_r_grain,'Color','blue');
        hold on
    end
    %Dessin de cet instant t
    drawnow
end