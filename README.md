# MATLAB-custom-steganography
LSB encoding of a text or a Grayscale or RGB image into a Graysale or RGB image.

English

/TODO

Spanish

Ésta práctica consiste en el desarrollo de una aplicación de esteganografía.

Se ha realizado un programa mediante Matlab, el cual permite cifrar textos o imágenes dentro de otras imágenes.

El cifrado se ha realizado mediante LSB, modificando el bit menos significativo de la imagen original, de tal forma que a simple vista no se aprecia la modificación sobre la imagen.

De esta forma, se pueden cifrar elementos cuyo tamaño sea 1/8 del tamaño del fichero original.

En los primeros bits cifrados, se ha creado una cabecera, indicando mediante un bit si es una imagen o texto, y los siguientes bits para el tamaño del texto o de la imagen.

El fichero de salida no puede ser jpg, ya que comprime la imagen y borra el mensaje.

La imagen contenedora debe estar en un formato cuyos datos sean de tipo uint8, por ejemplo <jpg o bmp>. 

El formato png actualmente no funciona ya que crea un array de uint16, el cifrado se realiza siempre sobre el bit nº 8 por lo que se deberían de realizar modificaciones para usar este formato.
