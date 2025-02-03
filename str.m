c = 'Hello World';

if strcmp(c, 'Hello World')  %比較兩個字串，回傳布林值
    disp('Strings are equal');
end

index = strfind(c, 'l');  %回傳字串開頭字母的位置，若沒找到則回傳空的陣列
disp(index);

newStr = strrep(c, 'World', 'MATLAB');  %將字串中的World改成MATLAB
disp(newStr);

s = "A horse! A horse! My kingdom for a horse!";

s = erase(s,"!");  %刪除指定的字串or字元
disp(s);

s = lower(s);  %將字串變成小寫
disp(s);

s = split(s);  %將字串從空白鍵中隔開
disp(s);

