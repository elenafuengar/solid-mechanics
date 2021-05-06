function [ c ] = ColorT( Tmin , Tmax , T , Cmap );

    n=length(Cmap(:,1));
    
    iTmin = n ;
    i0    = round ( (n+1)/2 );
    iTmax = 1 ;
    
    if T>=0
        i=round(  i0+(iTmax-i0)*T/Tmax    ) ;
        
    else
        i=round(  i0+(iTmin-i0)*T/Tmin    ) ;
    end
    
    c = Cmap(i,:);
end