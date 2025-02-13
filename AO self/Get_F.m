function [LB,UB,Dim,F_obj] = Get_F(F)
switch F
    case 'F1'
        F_obj = @F1;
        LB=-100;
        UB=100;
        Dim =30;
        
    case 'F2'
        F_obj = @F2;
        LB=-10;
        UB=10;
        Dim = 30;        
    case 'F3'
        F_obj = @F3;
        LB=-100;
        UB=100;
        Dim = 30;        
    case 'F4'
        F_obj = @F4;
        LB=-100;
        UB=100;
        Dim = 30;        
    case 'F5'
        F_obj = @F5;
        LB=-30;
        UB=30;
        Dim = 30;        
    case 'F6'
        F_obj = @F6;
        LB=-100;
        UB=100;
        Dim = 30;        
    case 'F7'
        F_obj = @F7;
        LB=-1.28;
        UB=1.28;
        Dim = 30;        
    case 'F8'
        F_obj = @F8;
        LB=-500;
        UB=500;
        Dim = 30;        
    case 'F9'
        F_obj = @F9;
        LB=-5.12;
        UB=5.12;
        Dim = 30;        
    case 'F10'
        F_obj = @F10;
        LB=-32;
        UB=32;
        Dim = 30;        
    case 'F11'
        F_obj = @F11;
        LB=-600;
        UB=600;
        Dim = 30;        
    case 'F12'
        F_obj = @F12;
        LB=-50;
        UB=50;
        Dim = 30;        
    case 'F13'
        F_obj = @F13;
        LB=-50;
        UB=50;
        Dim = 30;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% F1

function o = F1(x)
o=sum(x.^2);
end

% F2

function o = F2(x)
o=sum(abs(x))+prod(abs(x));
end

% F3

function o = F3(x)
dim=size(x,2);
o=0;
for i=1:dim
    o=o+sum(x(1:i))^2;
end
end

% F4

function o = F4(x)
o=max(abs(x));
end

% F5

function o = F5(x)
dim=size(x,2);
o=sum(100*(x(2:dim)-(x(1:dim-1).^2)).^2+(x(1:dim-1)-1).^2);
end

% F6

function o = F6(x)
o=sum(abs((x+.5)).^2);
end

% F7

function o = F7(x)
dim=size(x,2);
o=sum([1:dim].*(x.^4))+rand;
end

% F8

function o = F8(x)
o=sum(-x.*sin(sqrt(abs(x))));
end

% F9

function o = F9(x)
dim=size(x,2);
o=sum(x.^2-10*cos(2*pi.*x))+10*dim;
end

% F10

function o = F10(x)
dim=size(x,2);
o=-20*exp(-.2*sqrt(sum(x.^2)/dim))-exp(sum(cos(2*pi.*x))/dim)+20+exp(1);
end

% F11

function o = F11(x)
dim=size(x,2);
o=sum(x.^2)/4000-prod(cos(x./sqrt([1:dim])))+1;
end

% F12

function o = F12(x)
dim=size(x,2);
o=(pi/dim)*(10*((sin(pi*(1+(x(1)+1)/4)))^2)+sum((((x(1:dim-1)+1)./4).^2).*...
(1+10.*((sin(pi.*(1+(x(2:dim)+1)./4)))).^2))+((x(dim)+1)/4)^2)+sum(Ufun(x,10,100,4));
end

% F13

function o = F13(x)
dim=size(x,2);
o=.1*((sin(3*pi*x(1)))^2+sum((x(1:dim-1)-1).^2.*(1+(sin(3.*pi.*x(2:dim))).^2))+...
((x(dim)-1)^2)*(1+(sin(2*pi*x(dim)))^2))+sum(Ufun(x,5,100,4));
end

function o=Ufun(x,a,k,m)
o=k.*((x-a).^m).*(x>a)+k.*((-x-a).^m).*(x<(-a));
end
