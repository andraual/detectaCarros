clc;clear;
tic;
%Em vez de processar imediatamente todo o v�deo, 
%o exemplo come�a pela obten��o de uma moldura de v�deo inicial na qual
%os objetos em movimento s�o segmentados a partir do plano de fundo. 
%Isso ajuda a introduzir gradualmente as etapas usadas para processar o v�deo.
%O detector de primeiro plano requer um certo n�mero de quadros de v�deo para 
%inicializar o modelo de mistura gaussiana. Este exemplo usa os primeiros
%50 quadros para inicializar tr�s modos gaussianos no modelo de mistura.

foregroundDetector = vision.ForegroundDetector('NumGaussians', 3,'NumTrainingFrames', 150);
videoReader = vision.VideoFileReader('C:\Users\Andre\Desktop\UFABC\TG\video5.avi');
for i = 1:150
    frame = step(videoReader); % read the next video frame
    foreground = step(foregroundDetector, frame);
end

%Ap�s o treinamento, o detector come�a a produzir resultados de segmenta��o mais confi�veis. 
%As duas figuras abaixo mostram um dos quadros de v�deo ea m�scara de primeiro plano calculada pelo detector.

figure; imshow(frame); title('Video Frame');
figure; imshow(foreground); title('Foreground');

%O processo de segmenta��o de primeiro plano n�o � perfeito e muitas vezes inclui ru�do indesej�vel. 
%O exemplo usa abertura morfol�gica para remover o ru�do e preencher lacunas nos objetos detectados.

se = strel('square', 3);
filteredForeground = imopen(foreground, se);
%figure; imshow(filteredForeground); title('Clean Foreground');

%Em seguida, encontramos caixas delimitadoras de cada componente conectado
%correspondente a um carro em movimento usando o objeto vision.BlobAnalysis. 
%O objeto filtra ainda o primeiro plano detectado ao rejeitar blobs que cont�m menos de 150 pixels.

blobAnalysis = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
    'AreaOutputPort', false, 'CentroidOutputPort', false, ...
    'MinimumBlobArea', 150);
bbox = step(blobAnalysis, filteredForeground);

%Para destacar os carros detectados, desenhamos caixas verdes ao redor deles.

result = insertShape(frame, 'Rectangle', bbox, 'Color', 'green');

%O n�mero de caixas delimitadoras corresponde ao n�mero de carros encontrados na moldura de v�deo. 
%Exibimos o n�mero de carros encontrados no canto superior esquerdo do quadro de v�deo processado.

numCars = size(bbox, 1);
result = insertText(result, [10 10], numCars, 'BoxOpacity', 1, ...
    'FontSize', 14);
figure; imshow(result); title('Detected Cars');

%Na etapa final, processamos os quadros de v�deo restantes.

videoPlayer = vision.VideoPlayer('Name', 'Detected Cars');
videoPlayer.Position(3:4) = [750,450];  % window size: [width, height]
se = strel('square', 3); % morphological filter for noise removal


referenceimage=step(videoReader); 
X=zeros(2,121);

Y=zeros(2,121);

Z=zeros;



while ~isDone(videoReader)
    frame = step(videoReader); % read the next video frame
    foreground = step(foregroundDetector, frame);
    filteredForeground = imopen(foreground, se);
    
    
%-----------------------SPEED ---------------------------%
    frame2=((im2double(frame))-(im2double(referenceimage)));
    frame1=im2bw(frame2,0.1); 
    [Labelimage]=bwlabeln(frame1); 
    stats=regionprops(Labelimage,'basic');
    BB=stats.BoundingBox;
    i=2; %fblasst for
    X(i)=BB(1);
    Y(i)=BB(2);
    Dist=((X(i)-X(i-1))^2+(Y(i)-Y(i-1))^2)^(1/2);
    Z(i)=Dist;
    M=median(Z);

    Speed=((M)*(120/8))/(4);

    i = i + 1;
    SE = strel('disk',6); 
    frame3=imclose(frame1,SE); 
    step(videoReader); 
    pause(0.05);
      %if(i==121) end; ??
%-----------------------SPEED ---------------------------%
    
    
     blobAnalysis = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
    'AreaOutputPort', true, 'CentroidOutputPort', true, ...
    'MinimumBlobArea', 150);
    %bbox = step(blobAnalysis, filteredForeground);
    [areas, centroids, bbox] = step(blobAnalysis, filteredForeground);
    % Draw bounding boxes around the detected cars
    result = insertShape(frame, 'Rectangle', bbox, 'Color', 'green');
    % Display the number of cars found in the video frame
    %ICI
    %disp(centroids); //show...
    %disp(size(centroids));//show....
    numCars = size(bbox, 1); %cars ...
    numCars_str = ['car number:', num2str(size(bbox, 1))];
    speed_str = [num2str(Speed),'KM/h'];
    result = insertText(result,[10,10],numCars_str, 'BoxOpacity', 1, ...
        'FontSize', 14);
    for i=1:size(bbox, 1)
        result = insertText(result,[centroids(i,1),centroids(i,2)], speed_str, 'BoxOpacity', 1, 'FontSize', 10);
    end
    step(videoPlayer, result);  % display the results
    
    %bbox = step(blobAnalysis, filteredForeground);
    
    %disp(bbox(:,[1,2]))
    
    %result = insertShape(frame, 'Rectangle', bbox, 'Color', 'green');
    
    %numCars = size(bbox, 1);
    %result = insertText(result,bbox(:,[1,2]), 'm/s');
    %step(videoPlayer, result);  % display the results

end

release(videoReader); % close the video file
toc;