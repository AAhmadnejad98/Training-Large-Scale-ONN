zz = imread('device2.bmp','BMP');
abas = zz(:,:,1);
material=zeros(243,457);
index_SiO=1.5;
index_Si=3.5;
epsilon0=(1/(36*pi))*1e-9;

for i=1:243
    for j=1:457
        x= abas(i,j);
        if x>160
           material(i,j)= index_Si*index_Si*epsilon0;
        else
            material(i,j)= index_SiO*index_SiO*epsilon0;
        end
    end
end
material(120:125,:)=[];
material(:,end)=[];
material(1:17,:)=[];
material(205:end,:)=[];
main_material = [material material];
epsilon = ones(204*3,912*5)*index_SiO*index_SiO*epsilon0;

epsilon(2*204:end-1,1:912)=main_material;
epsilon(2*204:end-1,2*912:3*912-1)=main_material;
epsilon(2*204:end-1,4*912:5*912-1)=main_material;
% 
epsilon(204+8:2*204+7,912:2*912-1)=main_material;
epsilon(204+8:2*204+7,3*912:4*912-1)=main_material;

epsilon(16:204+15,2*912:3*912-1)=main_material;

epsilon(end-8:end-1,900:1850)= index_Si*index_Si*epsilon0;
epsilon(end-8:end-1,2700:3700)= index_Si*index_Si*epsilon0;

epsilon(212:219,1:912)= index_Si*index_Si*epsilon0;
epsilon(212:219,3650:end)= index_Si*index_Si*epsilon0;

epsilon(16:23,1:1825)= index_Si*index_Si*epsilon0;
epsilon(16:23,2720:end)= index_Si*index_Si*epsilon0;

% save("design_four.mat","epsilon")