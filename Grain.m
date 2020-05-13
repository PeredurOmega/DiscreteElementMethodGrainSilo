classdef Grain
    %GRAIN Cette classe représente un objet grain
    %   Elle permet d'améliorer la lisibilité du code par rapport à des
    %   tenseurs ou des matrices et utilise les capacités de POO de MATLAB
    
    properties
        mass=0.005; %Masse du grain en kg
        radius=0.006; %Rayon du grain en mètres
        position=Pair(0,0); %Coordonnées du grain en mètres
    end
    
    properties (Access = private)
        speed=Pair(0,0); %Vitesse du grain en mètres par seconde
        half_time_speed=Pair(0,0); %Vitesse de demi temps du grain en m.s^-1
        acceleration=Pair(0,0); %Accélération du grain en m.s^-2
        grain_drawing; %Dessin du grain
    end
    
    methods
        function grain = init(grain, position_x_0, position_y_0, mass, radius)
            %Fonction pour initialiser la position, la masse et le rayon du grain
            grain.position=Pair(position_x_0, position_y_0);
            grain.mass=mass;
            grain.radius=radius;
        end
        
        function grain = draw(grain)
            %Fonction pour dessiner un grain
            
            %Suppresion du dessin de l'ancienne position
            delete(grain.grain_drawing)
            
            %Récupération du facteur utiliser pour modéliser un grain
            global draw_factor
            
            %Dessin du grain
            grain.grain_drawing=plot(grain.position.x, grain.position.y, '.', 'Markersize', ((grain.radius)*(draw_factor)),'Color','blue');
        end
        
        function grain = compute_position_and_speed(grain)
            %Fonction pour calculer la nouvelle position et la nouvelle
            %vitesse d'un grain en utilisant le schéma de Verlet
            
            %Récupération du pas de temps
            global dt
            
            %Calcul de la nouvelle position en x
            grain.position.x=grain.position.x+grain.half_time_speed.x*dt;
            
            %Calcul de la nouvelle position en y
            grain.position.y=grain.position.y+grain.half_time_speed.y*dt;
            
            %Calcul de la nouvelle vitesse en x
            grain.speed.x=grain.half_time_speed.x+grain.acceleration.x*(dt/2);
            
            %Calcul de la nouvelle vitesse en y
            grain.speed.y=grain.half_time_speed.y+grain.acceleration.y*(dt/2);
        end
        
        function grain = compute_acceleration_and_half_time_speed(grain, force)
            %Fonction pour calculer l'accélération et la vitesse de demi
            %temps pour el schéma de Verlet.
            
            %Récupération du pas de temps
            global dt
            
            %Calcul de l'accélération en x
            grain.acceleration.x=force.x/grain.mass ;
            
            %Calcul de l'accélération en y
            grain.acceleration.y=force.y/grain.mass ;
        
            %Calcul de la vitesse de demi pas de temps en x
            grain.half_time_speed.x=grain.half_time_speed.x+grain.acceleration.x*dt;
            
            %Calcul de la vitesse de demi pas de temps en y
            grain.half_time_speed.y=grain.half_time_speed.y+grain.acceleration.y*dt;
        end
    end
end

