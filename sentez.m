clear all;
close all;
parser=parseMusicXML("muzik/nota.musicxml");

zarf_Secim = 1; % Zarf seçim değişkeni, 1 -> ADSR , 0 -> EXP Envelope.
har_Kac =1 ; % Harmonik seçim değişkeni. 1-> Asıl sinyali çalar.

A = 1; % Genlik değeri 1 olarak ayarlandı.
freq=size(parser); % Frekansların tutulacağı matris boş olarak oluşturuldu.
exp_Toplam = []; % Exp tipi zarfa girmiş notaların toplamı.
ADSR_Toplam = []; % ADSR tipi zarfa girmiş notaların toplamı.

freq_Uzunluk = size(freq); % Frekans matrisinin büyüklüğü alındı. (for döngüsüne bitiş değeri olarak vermek için).

for k= 1:freq(1) % For döngüsü başlangıcı.
    
      freq(k,1)=note(parser(k,4)); % Frekans değerleri note fonksiyonu yardımıyla oluşturuldu.
      zaman = 0: 1/10000 :parser(k,7); % t zamanlarını hesaplamak için gerekli değerler
      %parse edilmiş verinin ilgili sütunlarından çekildi.
      
      nota_Sinyal = A * cos(2*pi*freq(k,1)*zaman); % Nota sinyalleri oluşturuldu.
    
      harmonik_Sinyal=nota_Sinyal;
      
      %                              HARMONİKLER                          %
      
      if(har_Kac~=1) % Sinyalin harmoniklerinin alınıp alınmayacağına karar veren if yapısı.
      for n = 2:har_Kac
          A = 1/n;
          har_cosx = A * cos(2 * pi * freq(k,1) * zaman * n); % Sinyalin harmoniklerinin alınması.
          harmonik_Sinyal = harmonik_Sinyal + (har_cosx);
          
      end
      end
      
      %                              ZARF EKLENMESİ                       %
      
     if zarf_Secim == 1 % Hangi zarfın kullanılacağını seçmek için oluşturulan if-else yapısı başlangıcı.
      % ADSR tipi zarf yapısının uygulanması.
      dur = length(zaman);
      ADSR = [linspace(0,1.5,floor(dur/5)) linspace(1.5,1,ceil(dur/10)) ones(1,floor(dur/2)) linspace(1,0,floor(dur/5))];
      ADSR_Sinyal = ADSR .* harmonik_Sinyal; % Sinyallerin zarfa sokulması işlemi.
      ADSR_Toplam = [ADSR_Toplam ADSR_Sinyal]; % ADSR zarfına girmiş notaların tek bir matrise atılması.
      
      elseif zarf_Secim == 0 % Exponantial zarf seçimi.
    
      exp_Zarf = exp(-zaman / parser(k,2));
      
      % Exp zarf.
      exp_Sinyal = exp_Zarf .* harmonik_Sinyal; % Sinyallerin zarfa sokulması işlemi.
      exp_Toplam = [exp_Toplam exp_Sinyal];
      
     end % Seçim işleminin bittiği if-else yapısı sonu.
       
      
end 


    %               MELODİNİN ÇALDIRILMASI VE YANKI EKLENMESİ             %

    if zarf_Secim == 1
     
     ADSR_Toplam = (ADSR_Toplam)'; %ADSR zarfındaki melodiyi tutan matrisin transpozesinin alınması.   
     reverb = reverberator('PreDelay',0.15,'WetDryMix',0.2); % Reverb fonksiyonunun değerlerinin atanması.
     reverb_ADSR=reverb(ADSR_Toplam); % Reverb Fonksiyonunun kullanılması.
     sound(reverb_ADSR,10000) % Melodinin çaldırılması.
     
     plot(ADSR_Toplam) % Zarflı sinyalin çizdirilmesi.
     legend('ADSR tipi toplam sinyal.');
     figure
     plot(reverb_ADSR) % Zarflı ve yankılı sinyalin çizdirilmesi.
     legend('ADSR tipi,yankılı toplam sinyal.');

     
    elseif zarf_Secim == 0
        
     exp_Toplam = (exp_Toplam)';  % Exp zarfındaki melodiyi tutan matrisin transpozesinin alınması.   
     reverb = reverberator('PreDelay',0.15,'WetDryMix',0.2); % Reverb fonksiyonunun değerlerinin atanması.
     reverb_Exp=reverb(exp_Toplam);% Reverb Fonksiyonunun kullanılması.
     sound(reverb_Exp,10000) % Melodinin çaldırılması.
     
     plot(exp_Toplam) % Zarflı sinyalin çizdirilmesi.
     legend('Exp tipi toplam sinyal.');
     figure
     plot(reverb_Exp)% Zarflı ve yankılı sinyalin çizdirilmesi.
     legend('Exp tipi,yankılı toplam sinyal.');
     
    end
    
    figure
    plot(harmonik_Sinyal)
    legend('Yalın sinyal.');
    
    
    