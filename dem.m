clear all;
close all;

%Définition de la masse d'un grain
m_grain = 0.005;

%Rayon d'un grain de blé
r_grain = 0.0006;

%Définition de la pesanteur;
g=9.81;

%Définition du pas de temps
dt=0.001;

%Définition de la durée de la simulation
t_end=0.01;
t_count=t_end/dt;

%Définition du nombre de grains
grain_count=3;

% Définition de l'état initial (position + vitesse + accélération)
pos=zeros(1,2,grain_count, t_count);
for l=1:1:grain_count
    pos(:,:,l,1)=rand(1, 2); %Position aléatoire
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

%Boucle principale en fonction du temps
for t=1:1:t_count
    
    %Boucle sur tous les grains
    for i=1:1:grain_count
        %Récupération de la vitesse de demi-temps
        x_half_time_speed_i=half_time_speed(:,1,i);
        y_half_time_speed_i=half_time_speed(:,2,i);
        
        %Calcul de la nouvelle position du grain i
        pos(:,1,i,t+1)=pos(:,1,i,t)+x_half_time_speed_i*dt;
        pos(:,2,i,t+1)=pos(:,2,i,t)+y_half_time_speed_i*dt;
        
        %Calcul de la vitesse du grain i
        speed(:,1,i,t+1)=x_half_time_speed_i+acceleration(:,1,i,t)*dt;
        speed(:,2,i,t+1)=y_half_time_speed_i+acceleration(:,2,i,t)*dt;
        
        %Mise à jour de l'allongement delta des ressorts tangentiels.
        
    end
    
    %Boucle sur tous les grains
    for i=1:1:grain_count
        %Coordonnées du grain i
        x_grain_i=pos(:,1,i,t);
        y_grain_i=pos(:,2,i,t);
        
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
        force_i=[0 m_grain*g];
        
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
                    force_i(2)=force_i(2)+k*diff_x;
                else
                    force_i(2)=force_i(2)+k*diff_x;
                end
            end  
            
            %Application des forces de contacts en y sur i
            if abs(diff_y) < r_grain
                if diff_y < 0
                    force_i(2)=force_i(2)+k*diff_y;
                else
                    force_i(2)=force_i(2)+k*diff_y;
                end
            end
            
            %Incrémentation de la boucle
            k=k+1;
            
            %Si tous les voisins ont été contrôlés -> arrêt de la boucle
            if k>neighboors_count
                break;
            end
        end
        
        %Calcul de l'accélération du grain i
        %TODO
        
        %Calcul de la vitesse de demi pas de temps
        %TODO
    end
end