clc; 
clear all; 
close all;
%ser = serial('COM32','BaudRate',9600);
vid = videoinput('winvideo',1,'YUY2_640x480')';
set(vid,'FramesPerTrigger',1);
start(vid);
preview(vid);
figure('units','normalized','outerposition',[0 0 1 1]);
RectangleInserter = vision.ShapeInserter('Shape','Rectangles','Fill',true,'FillColorSource','Input port');
CircleInserter = vision.ShapeInserter('Shape','Circles','Fill',true,'FillColorSource','Input port');
FaceDetector = vision.CascadeObjectDetector('FrontalFaceLBP');
FaceDetector.MinSize = [96,96];
FaceDetector.MaxSize = [432,432];
EyePairDetector = vision.CascadeObjectDetector('EyePairBig');
EyePairDetector.MinSize = [11,45];
EyePairDetector.MaxSize = [99,405];
HorizontalBar = 50;
VerticalBar = 50;
%fopen(ser);    
while(1)
    HorizontalPupilPosition=0;
    VerticalPupilPosition=0;
    CompleteImage = ycbcr2rgb(getsnapshot(vid));
    CompleteImage = flip(CompleteImage,2);
    FaceLocation = step(FaceDetector,CompleteImage);
    if(size(FaceLocation)~=0)
        FaceLocation = FaceLocation(1,:);
        TopFaceImage = CompleteImage(FaceLocation(2):FaceLocation(2)+(FaceLocation(4)-1)/2,FaceLocation(1):FaceLocation(1)+FaceLocation(3)-1,1);
        CompleteImage = insertObjectAnnotation(CompleteImage,'rectangle',FaceLocation,'Detected Face','color',[0,0,0],'TextColor',[255,255,255],'FontSize',8);
        EyePairLocation = step(EyePairDetector,TopFaceImage);
        if(size(EyePairLocation)~=0)
            EyePairLocation = EyePairLocation(1,:);
            LeftEyeLocation = [FaceLocation(1)+EyePairLocation(1)-1,FaceLocation(2)+EyePairLocation(2)-1,EyePairLocation(3)/3,EyePairLocation(4)];
            RightEyeLocation = [FaceLocation(1)+EyePairLocation(1)+2*EyePairLocation(3)/3-1,FaceLocation(2)+EyePairLocation(2)-1,EyePairLocation(3)/3,EyePairLocation(4)];
            LeftEyeImage = CompleteImage(LeftEyeLocation(2):LeftEyeLocation(2)+LeftEyeLocation(4)-1,LeftEyeLocation(1):LeftEyeLocation(1)+LeftEyeLocation(3)-1,1);
            RightEyeImage = CompleteImage(RightEyeLocation(2):RightEyeLocation(2)+RightEyeLocation(4)-1,RightEyeLocation(1):RightEyeLocation(1)+RightEyeLocation(3)-1,1);   
            CompleteImage = insertObjectAnnotation(CompleteImage,'rectangle',LeftEyeLocation,'Left Eye','color',[100,0,0],'TextColor',[255,255,255],'FontSize',8);
            CompleteImage = insertObjectAnnotation(CompleteImage,'rectangle',RightEyeLocation,'Right Eye','color',[100,0,0],'TextColor',[255,255,255],'FontSize',8);   
            DualEyeImage = uint16(LeftEyeImage)+uint16(RightEyeImage);
            DualEyeSize = size(DualEyeImage);
            DualEyeImage = DualEyeImage(DualEyeSize(1)/6:5*DualEyeSize(1)/6,DualEyeSize(2)/6:5*DualEyeSize(2)/6);
            DualEyeSize = size(DualEyeImage);
            PupilColor = 1.3*min(DualEyeImage(:));
            count=0;
            for row = 1:DualEyeSize(1)
                for column = 1:DualEyeSize(2)
                    if(DualEyeImage(row,column) < PupilColor)
                        HorizontalPupilPosition = HorizontalPupilPosition+column;
                        VerticalPupilPosition = VerticalPupilPosition+row;
                        count=count+1;
                    end;
                end;
            end;
            HorizontalPupilPosition = HorizontalPupilPosition/count/DualEyeSize(2)*100;
            VerticalPupilPosition = VerticalPupilPosition/count/DualEyeSize(1)*100;
            HorizontalBar = (HorizontalBar*4 +HorizontalPupilPosition)/5;
            VerticalBar = (VerticalBar*4 + VerticalPupilPosition)/5;
            if(HorizontalBar > 67)
                BotMotion = 3;
            elseif(HorizontalBar < 47)
                BotMotion = 4;    
            elseif(VerticalBar > 67)
                BotMotion = 2;
            elseif(VerticalBar < 51)
                BotMotion = 1;   
            else
                BotMotion = 0;
            end;
        else
            BotMotion=0;
        end;
    else
        BotMotion=0;
    end;
    CompleteImage=step(RectangleInserter,CompleteImage,int32([HorizontalBar*5.2+40-1,440,3,20]),uint8([255,149,0]));
    CompleteImage=step(RectangleInserter,CompleteImage,int32([601,VerticalBar*3.2+60-1,20,3]),uint8([255,149,0]));    
    CompleteImage = insertObjectAnnotation(CompleteImage,'rectangle',[40,450,1,1],HorizontalPupilPosition,'color',[0,100,0],'TextColor',[255,255,255],'FontSize',8);   
    CompleteImage = insertObjectAnnotation(CompleteImage,'rectangle',[610,60,1,1],VerticalPupilPosition,'color',[0,100,0],'TextColor',[255,255,255],'FontSize',8);
    CompleteImage=step(RectangleInserter,CompleteImage,int32([40,450,560,3]),uint8([0,0,100]));
    CompleteImage=step(RectangleInserter,CompleteImage,int32([610,60,3,320]),uint8([0,0,100]));
    CompleteImage = insertObjectAnnotation(CompleteImage,'rectangle',[5,5,1,1],BotMotion,'color',[120,0,0],'TextColor',[0,0,0],'FontSize',12);
    %fwrite(ser,BotMotion);
    image(CompleteImage);
    title('Facial And Eye Pair Recognition');
    drawnow;
end;