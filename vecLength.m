function len = vecLength1(vec)

sum = 0;
for i = 1:length(vec)
    disp(i);
    sum = sum+vec(i)*vec(i);
    disp(sum);
end
len = sqrt(sum);

end


vector = [3 4 5 6 7;2 3 5 6 9];
len = vecLength1(vector);
disp(len);