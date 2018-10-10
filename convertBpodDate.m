% convert Bpot string date to actual date that sorts properly

function out = convertBpodDate(dateString,startOfMonth)

thisMonth = dateString(startOfMonth:startOfMonth+2);
thisDay = dateString(startOfMonth+3:startOfMonth+4);
thisYear = dateString(startOfMonth+8:startOfMonth+9);

switch thisMonth
    case 'Jan'
        monthNum = '01';
    case 'Feb'
        monthNum = '02';
    case 'Mar'
        monthNum = '03';
    case 'Apr'
        monthNum = '04';
    case 'May'
        monthNum = '05';
    case 'Jun'
        monthNum = '06';
    case 'July'
        monthNum = '07';
    case 'Aug'
        monthNum = '08';
    case 'Sep'
        monthNum = '09';
    case 'Oct'
        monthNum = '10';
    case 'Nov'
        monthNum = '11';
    case 'Dec'
        monthNum = '12';
end

out = [dateString(1:startOfMonth-1) ...
       thisYear monthNum thisDay ...
       dateString(startOfMonth+10:end)];



