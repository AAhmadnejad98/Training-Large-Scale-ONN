clear ;
clc;
factor=6;
S=1/(2^0.5);
epsilon0=(1/(36*pi))*1e-9;
mu0=4*pi*1e-7; c=3e+8;
delta=0.25e-6/factor;
deltat=S*delta/c;
time_tot=20000;
ydim=760*factor;%The domain is 30*factor space steps or 32*0.25=8 microns long
xdim=102*factor;%The domain is 80*factor space steps or 80*0.25=20 microns wide
wav=1.5;

epsilon = load("design_four.mat").epsilon;
epsilon(116:118,:)=[];
epsilon(309:311,:)=[];
epsilon(502:504,:)=[];
epsilon(1,:)=[];
epsilon(115,:)=[];
epsilon(307,:)=[];
epsilon(499,:)=[];
epsilon(1,:)=[];
xdim = 598;
ydim = 4560;
mu=mu0*ones(xdim,ydim);
Ez=zeros(xdim,ydim);
Ezx=zeros(xdim,ydim);
Ezy=zeros(xdim,ydim);
Hy=zeros(xdim,ydim);
Hx=zeros(xdim,ydim);

Initializing electric conductivity matrices in x and y directions
sigmax=zeros(xdim,ydim);
sigmay=zeros(xdim,ydim);


%Perfectly matched layer boundary design
%Boundary width of PML in all directions
bound_width=factor*4;
%Order of polynomial on which sigma is modeled
gradingorder=6;
%Required reflection co-efficient
refl_coeff=1e-6;
%Polynomial model for sigma
sigmamax=(-log10(refl_coeff)*(gradingorder+1)*epsilon0*c)/(2*bound_width*delta);
boundfact1=((epsilon(xdim/2,bound_width)/epsilon0)*sigmamax)/((bound_width^gradingorder)*(gradingorder+1));
boundfact2=((epsilon(xdim/2,ydim-bound_width)/epsilon0)*sigmamax)/((bound_width^gradingorder)*(gradingorder+1));
boundfact3=((epsilon(bound_width,ydim/2)/epsilon0)*sigmamax)/((bound_width^gradingorder)*(gradingorder+1));
boundfact4=((epsilon(xdim-bound_width,ydim/2)/epsilon0)*sigmamax)/((bound_width^gradingorder)*(gradingorder+1));
x=0:1:bound_width;
for i=1:1:xdim
    sigmax(i,bound_width+1:-1:1)=boundfact1*((x+0.5*ones(1,bound_width+1)).^(gradingorder+1)-(x-0.5*[0 ones(1,bound_width)]).^(gradingorder+1));
    sigmax(i,ydim-bound_width:1:ydim)=boundfact2*((x+0.5*ones(1,bound_width+1)).^(gradingorder+1)-(x-0.5*[0 ones(1,bound_width)]).^(gradingorder+1));
end
for i=1:1:ydim
    sigmay(bound_width+1:-1:1,i)=boundfact3*((x+0.5*ones(1,bound_width+1)).^(gradingorder+1)-(x-0.5*[0 ones(1,bound_width)]).^(gradingorder+1))';
    sigmay(xdim-bound_width:1:xdim,i)=boundfact4*((x+0.5*ones(1,bound_width+1)).^(gradingorder+1)-(x-0.5*[0 ones(1,bound_width)]).^(gradingorder+1))';
end

%Magnetic conductivity matrix obtained by Perfectly Matched Layer condition
sigma_starx=(sigmax.*mu)./epsilon;
sigma_stary=(sigmay.*mu)./epsilon;

%Multiplication factor matrices for H matrix update to avoid being calculated many times in the time update loop so as to increase computation speed
G=((mu-0.5*deltat*sigma_starx)./(mu+0.5*deltat*sigma_starx));
H=(deltat/delta)./(mu+0.5*deltat*sigma_starx);
A=((mu-0.5*deltat*sigma_stary)./(mu+0.5*deltat*sigma_stary));
B=(deltat/delta)./(mu+0.5*deltat*sigma_stary);

%Multiplication factor matrices for E matrix update to avoid being calculated many times in the time update loop so as to increase computation speed
C=((epsilon-0.5*deltat*sigmax)./(epsilon+0.5*deltat*sigmax));
D=(deltat/delta)./(epsilon+0.5*deltat*sigmax);
E=((epsilon-0.5*deltat*sigmay)./(epsilon+0.5*deltat*sigmay));
F=(deltat/delta)./(epsilon+0.5*deltat*sigmay);

% Update loop begins
for n=1:1:time_tot
    %matrix update instead of for-loop for Hy and Hx fields
    Hy(1:xdim-1,1:ydim-1)=A(1:xdim-1,1:ydim-1).*Hy(1:xdim-1,1:ydim-1)+B(1:xdim-1,1:ydim-1).*(Ezx(2:xdim,1:ydim-1)-Ezx(1:xdim-1,1:ydim-1)+Ezy(2:xdim,1:ydim-1)-Ezy(1:xdim-1,1:ydim-1));
    Hx(1:xdim-1,1:ydim-1)=G(1:xdim-1,1:ydim-1).*Hx(1:xdim-1,1:ydim-1)-H(1:xdim-1,1:ydim-1).*(Ezx(1:xdim-1,2:ydim)-Ezx(1:xdim-1,1:ydim-1)+Ezy(1:xdim-1,2:ydim)-Ezy(1:xdim-1,1:ydim-1));

    %matrix update instead of for-loop for Ez field
    Ezx(2:xdim,2:ydim)=C(2:xdim,2:ydim).*Ezx(2:xdim,2:ydim)+D(2:xdim,2:ydim).*(-Hx(2:xdim,2:ydim)+Hx(2:xdim,1:ydim-1));
    Ezy(2:xdim,2:ydim)=E(2:xdim,2:ydim).*Ezy(2:xdim,2:ydim)+F(2:xdim,2:ydim).*(Hy(2:xdim,2:ydim)-Hy(1:xdim-1,2:ydim));

    % Source condition incorporating given free space wavelength 'wav' and having a location at the left end of central waveguide just after PML boundary
    tstart=1;
    N_lambda=wav*1e-6/delta;
    Ezx(207:214,25)=0.5*sin(((2*pi*(c/(delta*N_lambda))*(n-tstart)*deltat)));
    Ezy(207:214,25)=0.5*sin(((2*pi*(c/(delta*N_lambda))*(n-tstart)*deltat)));


    Ezx(399:406,25)=0.5*sin(((2*pi*(c/(delta*N_lambda))*(n-tstart)*deltat)));
    Ezy(399:406,25)=0.5*sin(((2*pi*(c/(delta*N_lambda))*(n-tstart)*deltat)));


    Ez=Ezx+Ezy;
    disp(['ITER----->>>:' num2str(n)]);
end
imagesc(Ez)
xlabel("X")
ylabel("Y")
title("4\times 4 MZI")