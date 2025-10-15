function [v1] = newV(v0, x0, c1, p_best, c2, g_best)
    v0Size = size(v0);
    v0VecNum = v0Size(1);
    v0Dim = v0Size(2);
    v1 = zeros(v0VecNum,v0Dim);
    w = rand(v0VecNum,1)*0.6+0.4;
    %w = 0.9;
    p1 = rand(v0VecNum,v0Dim);
    p2 = rand(v0VecNum,v0Dim);
    %p2 = ones(v0VecNum,v0Dim)-p1;
    for i = 1:v0VecNum
        v1(i,:) = w(i)*v0(i,:) + c1*p1(i,:).*(p_best-x0) + c2*p2(i,:).*(g_best-x0);
    end
end