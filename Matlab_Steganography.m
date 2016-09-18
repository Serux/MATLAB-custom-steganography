%% Definición de características.

%Cabecera de mensaje cifrado:
%(Si se modifican estas características, el programa debería seguir
%funcionando, ya que todos los cálculos con tamaños de la cabecera se 
%han realizado usando estas variables)

%1 bit tipo de datos (texto-imagen)
BitsTipoDatos = 1;
%11 bits por altitud (máximo 2047)
BitsAltitud = 11;
%11 bits por longitud (máximo 2047)
BitsLongitud = 11;
%1 bit por blanco y negro o rgb.
BitsColor = 1;
%21 bits por longitud de texto,
BitsStringLength = 23;

%La tamaño máximo de la imagen contenida o del texto no podrá ser mayor 
%que estos valores, pero el tamaño máximo final se verá limitado por el
%tamaño de la imagen contenedora (por cada byte se puede cifrar un bit,
%por lo tanto se puede cifrar un archivo de tamaño 1/8)

BytesTotalesCabeceraImagen= (BitsTipoDatos + BitsAltitud + BitsLongitud + BitsColor)/8;
BytesTotalesCabeceraTexto = (BitsTipoDatos + BitsStringLength)/8;

opcionMenu = input('Introduce 0 para salir, 1 para cifrar o 2 para descifrar: ');
while opcionMenu ~= 0
    if opcionMenu == 1
        %% CODIFICAR
        tipomensajequeseintroducira= -1;
        while tipomensajequeseintroducira ~=0 && tipomensajequeseintroducira ~=1
            tipomensajequeseintroducira = input('Introduce 0 para cifrar texto o 1 para cifrar imagen: ');
        end
        
        %% Obtener imagen sobre la que se introducirá mensaje oculto.
        continuar = false;
        disp('Selecciona una imagen sobre la que introducir el mensaje');
        while  ~continuar;
            %obtiene la ruta mediante gestor de windows.
            [fichero,ruta]=uigetfile({'*.jpg;*.bmp'},'Selecciona una imagen a cargar');
            %exist con dos argumentos para mejorar rendimiento
            if exist(cat(2,ruta,fichero),'file') ~= 0;
                A = imread(cat(2,ruta,fichero));
                continuar = true;
            end
        end
        sizeX=size(A,1);
        sizeY=size(A,2);
        sizeZ=size(A,3);
        
        
        %% Convierte imagen en representación binaria.
        disp('Convirtiendo a representación binaria');
        Abin=dec2bin(A,8);
        ABinVaciada = Abin;
        
        %% Vacía último bit todos los píxeles de la imagen.
        disp('Vaciando último bit de toda la imagen');
        ABinVaciada(:,8) = '0';
        
        %% Convertir Representación binaria en imagen pasa mostrarla.
        disp('Convirtiendo a imagen Vacía');
        AVaciada=uint8(bin2dec(ABinVaciada));
        AVaciada=reshape(AVaciada,sizeX,sizeY,sizeZ);
        
        
        %% Procesado de mensaje para introducirlo en la imagen
        if tipomensajequeseintroducira == 0
            %% Introducción mensaje de texto.
            maxTextSize= size(Abin,1)/8;
            texto = input(['Introduce mensaje a cifrar, máximo (', num2str(maxTextSize - BytesTotalesCabeceraTexto), ' letras ):'],'s');
            while size(texto,2) > maxTextSize
                disp('Mensaje demasiado largo');
                texto = input(['Introduce mensaje a cifrar, máximo (', num2str(maxTextSize-BytesTotalesCabeceraTexto), ' letras ):'],'s');
            end
            
            %Prepara el mensaje a cifrar
            disp('Procesando mensaje a cifrar');
            longitudTexto = size(texto,2);
            textoBin = dec2bin(texto,8);
            mensaje = reshape(textoBin,1,[]);
            longitudBin = dec2bin(longitudTexto,BitsStringLength);
            %Prepara una cabecera, indicando el tipo (texto) y la longitud del
            %mensaje.
            Cabecera= ['0',longitudBin];
        else
            %% Introducción de imagen.
            continuar = false;
            disp('Introduce la imagen a ser cifrada');
            disp(['Tamaño máximo ', num2str(2^BitsAltitud),'*',num2str(2^BitsLongitud)]);
            while  ~continuar;
                %obtiene la ruta mediante gestor de windows.
                [fichero,ruta]=uigetfile({'*.jpg;*.bmp;*.png'},'Selecciona una imagen a cargar');
                %exist con dos argumentos para mejorar rendimiento
                if exist(cat(2,ruta,fichero),'file') ~= 0;
                    B = imread(cat(2,ruta,fichero));
                    BsizeX= size(B,1);
                    BsizeY= size(B,2);
                    BsizeZ= size(B,3);
                    BtotalSize= BsizeX*BsizeY*BsizeZ;
                    if BtotalSize < size(Abin,1)/8;
                        continuar = true;
                    else
                        disp(['Imagen demasiado grande, se pueden cifrar ', num2str((size(Abin,1)/8)-BytesTotalesCabeceraImagen), ' bytes y la imagen ocupa ' num2str(BtotalSize)])
                    end
                end
            end
            disp('Procesando imagen a cifrar');
            mensaje=dec2bin(B);
            mensaje = reshape(mensaje,1,[]);
            
            
            BsizeX=dec2bin(BsizeX,BitsAltitud);
            BsizeY=dec2bin(BsizeY,BitsLongitud);
            
            %Codificar 0 para grayscale o 1 para rgb
            if BsizeZ==1
                BsizeZ='0';
            else
                BsizeZ='1';
            end
            %Prepara la cabecera, con el tipo de dato y las dimensiones de la
            %imagen.
            Cabecera= ['1',BsizeX,BsizeY,BsizeZ];
        end
        
        
        
        %% Introducción del mensaje preparado en la imagen
        %En el bit 1 el tipo de dato
        % 0 para texto, 1 para imagen
        
        %Si es imagen
        %En los bits 2-12 se guarda el tamaño X
        %En los bits 13-23 se guarda el tamaño Y
        %En el bit 24 se grayscale o rgb.
        
        %Si es texto
        %En los bits 2-22 se guarda la longitud de la cadena.
        
        mensajeConCabecera= [Cabecera,mensaje];
        
        disp('Introduciendo mensaje en stream');
        ABinRellena = ABinVaciada;
        %Rellena el bit nº8 con el mensaje.
        ABinRellena(1:size(mensajeConCabecera,2),8) = mensajeConCabecera;
        
        disp('Convirtiendo en imagen con mensaje cifrado');
        ARellena=uint8(bin2dec(ABinRellena));
        ARellena=reshape(ARellena,sizeX,sizeY,sizeZ);
        
        %% guardar imagen final.
        imwrite(ARellena,'ImagenConMensaje.bmp');
        
        
        %% Muestra imágen original, con el último bit vacío y con el cifrado.
        figure;
        subplot(1,3,1);
        imshow(A);
        title('Imagen original');
        subplot(1,3,2)
        imshow(AVaciada);
        title('Imagen con último bit vacío');
        subplot(1,3,3)
        imshow(ARellena);
        title('Imagen con mensaje en el último bit');
        
        %Limpiamos las variables creadas para que no interfieran en otras
        %ejecuciones.
        clear A
        clear Abin
        clear AVaciada
        clear ABinVaciada
        clear ARellena
        clear ABinRellena
        clear mensaje
        clear mensajeConCabecera
        clear sizeX
        clear sizeY
        clear sizeZ
        clear texto
        clear textoBin
        clear maxTextSize
        clear Cabecera
        clear longitudBin
        clear longitudTexto
        clear continuar;
        clear fichero;
        clear ruta;
    elseif opcionMenu == 2
        %% DESCODIFICAR
        %obtener imagen
        disp('Introduce una imagen para descodificar');
        continuar = false;
        while  ~continuar;
            %obtiene la ruta mediante gestor de windows.
            [fichero,ruta]=uigetfile('.bmp','Selecciona una imagen a cargar');
            %exist con dos argumentos para mejorar rendimiento
            if exist(cat(2,ruta,fichero),'file') ~= 0;
                ARellena = imread(cat(2,ruta,fichero));
                continuar = true;
            end
        end
        
        
        %% RecuperarMensaje
        ImagenConMensajeBin=dec2bin(ARellena);
        tipoDatoResultado = ImagenConMensajeBin(BitsTipoDatos,8);
        
        %En el bit 1 el tipo de dato
        % 0 para texto, 1 para imagen
        if tipoDatoResultado == '0'
            %% Descodifica Texto
            % En los bits 2-24 se guarda la longitud de la cadena.
            % Leemos la cabecera
            lengthResultado = ImagenConMensajeBin(BitsTipoDatos+1:BitsTipoDatos+BitsStringLength,8);
            %%
            lengthResultado = bin2dec(lengthResultado');
            % leemos el resto del mensaje.
            MensajeTextoBin = ImagenConMensajeBin(BitsTipoDatos+BitsStringLength+1:BitsTipoDatos+BitsStringLength+8*lengthResultado,8)';
            MensajeTextoBin = reshape(MensajeTextoBin,lengthResultado,8);
            MensajeTextoDescifrado = char(uint8(bin2dec(MensajeTextoBin)))';
            disp(['El mensaje era: ', MensajeTextoDescifrado]);
            clear lengthResultado
            clear MensajeTextoDescifrado
            clear MensajeTextoBin
        else
            %% Descodifica Imagen
            %En los bits 2-12 se guarda el tamaño X
            %En los bits 13-23 se guarda el tamaño Y
            %En el bit 24 se guarda grayscale o rgb.
            
            % Leemos la cabecera
            %Guardamos la altitud.
            InicioSiguienteDato = BitsTipoDatos+1;
            FinalSiguienteDato  = BitsTipoDatos+BitsAltitud;
            altitudResultado    = ImagenConMensajeBin(InicioSiguienteDato:FinalSiguienteDato,8);
            altitudResultado    = bin2dec(altitudResultado');
            
            %Guardamos la longitud.
            InicioSiguienteDato= InicioSiguienteDato+BitsAltitud;
            FinalSiguienteDato = FinalSiguienteDato+BitsLongitud;
            longitudResultado   = ImagenConMensajeBin(InicioSiguienteDato:FinalSiguienteDato,8);
            longitudResultado = bin2dec(longitudResultado');
            
            %Guardamos la profundidad.
            InicioSiguienteDato= InicioSiguienteDato+BitsLongitud;
            FinalSiguienteDato = FinalSiguienteDato+BitsColor;
            profundidadResultado= ImagenConMensajeBin(InicioSiguienteDato:FinalSiguienteDato,8);
            profundidadResultado= bin2dec(profundidadResultado');
            if profundidadResultado == 0
                profundidadResultado = 1;
            else
                profundidadResultado = 3;
            end
            
            %Guardamos el mensaje cifrado.
            InicioSiguienteDato= InicioSiguienteDato+BitsColor;
            imagenResultadoStream= ImagenConMensajeBin(InicioSiguienteDato:InicioSiguienteDato-1+longitudResultado*altitudResultado*profundidadResultado*8,8);
            
            %transformamos el mensaje en una imagen y la mostramos.
            imagenResultado = reshape(imagenResultadoStream,size(imagenResultadoStream,1)/8,8);
            imagenResultado = uint8(bin2dec(imagenResultado));
            imagenResultado = reshape(imagenResultado,altitudResultado,longitudResultado,profundidadResultado);
            figure
            imshow(uint8(imagenResultado));
            title('Imagen descifrada');
            
        end
        clear ARellena
        clear continuar
        clear fichero
        clear ImagenConMensajeBin
        clear ruta
        clear tipoDatoResultado
    end
    opcionMenu = input('Introduce 0 para salir, 1 para cifrar o 2 para descifrar: ');
end
