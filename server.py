from flask import Flask, request, jsonify
import cv2
import numpy as np
import requests 
import face_recognition

import tensorflow as tf

import tensorflow_hub as hub

# For downloading the image.
import matplotlib.pyplot as plt
import tempfile
import urllib.request 
import requests
from six import BytesIO
import io

# For drawing onto the image.
import numpy as np
from PIL import Image
from PIL import ImageColor
from PIL import ImageDraw
from PIL import ImageFont
from PIL import ImageOps
import traceback


# For measuring the inference time.
import time
import os, subprocess
import certifi
import ssl

from reportlab.lib.pagesizes import letter
from reportlab.lib.units import inch
from reportlab.pdfgen import canvas
from reportlab.lib.utils import ImageReader
from reportlab.lib.styles import ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Paragraph
import requests
from datetime import datetime
import pytz



app = Flask(__name__)


# This list will store the data from POST requests
images = []

import requests
import cv2
import face_recognition

def image_scanner(idImage, faceImage):
    id_image_url = idImage['ID_Link']
    face_image_url = faceImage['Face_Link']

    # Retrieve ID image using requests
    id_image_response = requests.get(id_image_url, verify=False)
    with open('./idImage.jpg', 'wb') as id_image_file:
        id_image_file.write(id_image_response.content)
    
    face_image_response = requests.get(face_image_url, verify=False)
    with open('./faceImage.jpg', 'wb') as face_image_file:
        face_image_file.write(face_image_response.content)
    
    # Face detection
    img = cv2.imread("./idImage.jpg")
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    faceCascade = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_frontalface_default.xml")
    faces = faceCascade.detectMultiScale(
        gray,
        scaleFactor=1.3,
        minNeighbors=3,
        minSize=(30, 30)
    )
    idName = ''

    idName1= ''
    idName2=''
    count = 1
    for (x, y, w, h) in faces:
        cv2.rectangle(img, (x, y), (x + w, y + h), (0, 255, 0), 2)
        roi_color = img[y:y + h, x:x + w]
        print("[INFO] Object found. Saving locally.")
        cv2.imwrite(str(w) + str(h) + '_faces.jpg', roi_color)
        if count == 1:
            idName1=  str(w) + str(h) + '_faces'
        if count == 2:
            idName2= str(w) + str(h) + '_faces'
        count += 1
        idName = str(w) + str(h) + '_faces'

    # Face comparison
    #ref_image = face_recognition.load_image_file("./faceImage.jpg")
    ref_image = face_recognition.load_image_file(f"./{idName2}.jpg")
    ref_encodings = face_recognition.face_encodings(ref_image)

    if len(ref_encodings) == 0:
        return {'error': 'No face detected in the reference image'}

    target_image = face_recognition.load_image_file(f"./{idName1}.jpg")
    target_encodings = face_recognition.face_encodings(target_image)

    if len(target_encodings) == 0:
        return {'error': 'No face detected in the target image'}

    results = face_recognition.compare_faces(ref_encodings, target_encodings[0])
    result = ''
    if results[0]:
        result = "The faces are similar"
    else:
        result = "The faces are not similar"

    return {'load_status': result}



#ID Verification endpoint
@app.route('/images', methods=['GET', 'POST'])
def image():
    if request.method == 'POST':
        # Get the data from the POST request
        data = request.get_json()
        # Add the data to the list
        images.append(data)
        return jsonify({'message': 'POST request received'}), 200
    else:
        # Return the list of images in the response to GET requests
        loaded = ''
        if len(images) >= 2:
            #when both images load call similarity function and reset images
            loaded = image_scanner(images[0],images[1])


        return jsonify(loaded), 200


def download_and_resize_image(image_url, new_size):
    # Download the image from the URL
    filename= 'testImage.jpg'
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"
    }
    response = requests.get(image_url)
    response.raise_for_status()  # Check for any download errors

    image_data = response.content

    # Open the downloaded image using PIL
    image = Image.open(io.BytesIO(image_data))
    image = ImageOps.fit(image, new_size, Image.LANCZOS)


    image = image.convert('RGB')

    # Resize the image
    current_dir = os.getcwd()
    save_path = os.path.join(current_dir, filename)
    image.save(filename, format="JPEG", quality=90)
    

    return filename

def draw_bounding_box_on_image(image,
                                ymin,
                                xmin,
                                ymax,
                                xmax,
                                color,
                                font,
                                thickness=4,
                                display_str_list=()):
    """Adds a bounding box to an image."""
    draw = ImageDraw.Draw(image)
    im_width, im_height = image.size
    (left, right, top, bottom) = (xmin * im_width, xmax * im_width,
                                  ymin * im_height, ymax * im_height)
    draw.line([(left, top), (left, bottom), (right, bottom), (right, top),
              (left, top)],
              width=thickness,
              fill=color)

    # If the total height of the display strings added to the top of the bounding
    # box exceeds the top of the image, stack the strings below the bounding box
    # instead of above.
    font_size = 30
    display_str_heights = [font_size for ds in display_str_list]
    # Each display_str has a top and bottom margin of 0.05x.
    total_display_str_height = (1 + 2 * 0.05) * sum(display_str_heights)

    if top > total_display_str_height:
      text_bottom = top
    else:
      text_bottom = top + total_display_str_height
    # Reverse list and print from bottom to top.
    for display_str in display_str_list[::-1]:
      text_width, text_height = [font_size, font_size]
      margin = np.ceil(0.05 * text_height)
      draw.rectangle([(left, text_bottom - text_height - 2 * margin),
                      (left + text_width, text_bottom)],
                    fill=color)
      draw.text((left + margin, text_bottom - text_height - margin),
                display_str,
                fill="black",
                font=font)
      text_bottom -= text_height - 2 * margin

def draw_boxes(image, boxes, class_names, scores, max_boxes=10, min_score=0.1):
    """Overlay labeled boxes on an image with formatted scores and label names."""
    colors = list(ImageColor.colormap.values())

    try:
      font = ImageFont.truetype("liberation-sans-narrow/LiberationSansNarrow-Regular.ttf",
                                25)
    except IOError:
      print("Font not found, using default font.")
      font = ImageFont.load_default()

    for i in range(min(boxes.shape[0], max_boxes)):
      if scores[i] >= min_score:
        ymin, xmin, ymax, xmax = tuple(boxes[i])
        display_str = "{}: {}%".format(class_names[i].decode("ascii"),
                                      int(100 * scores[i]))
        color = colors[hash(class_names[i]) % len(colors)]
        image_pil = Image.fromarray(np.uint8(image)).convert("RGB")
        draw_bounding_box_on_image(
            image_pil,
            ymin,
            xmin,
            ymax,
            xmax,
            color,
            font,
            display_str_list=[display_str])
        np.copyto(image, np.array(image_pil))
    return image


def load_img(path):
    img = tf.io.read_file(path)
    img = tf.image.decode_jpeg(img, channels=3)
    return img




current_dir = os.getcwd()
model_path = os.path.join(current_dir, 'model')
  
  #will figure out better performance later


  #for AWS hosting files need to be saved on EC3.

 
  
def run_detector(image_url):
    downloaded_image_path = download_and_resize_image(image_url, (1280, 856))
    module_handle = "https://tfhub.dev/google/openimages_v4/ssd/mobilenet_v2/1" #pretrained model
    detector = hub.load(module_handle).signatures['default']
    print('reached here')

    img = load_img(downloaded_image_path)

    converted_img  = tf.image.convert_image_dtype(img, tf.float32)[tf.newaxis, ...]
    start_time = time.time()
    result = detector(converted_img)
    end_time = time.time()

    result = {key:value.numpy() for key,value in result.items()}

    print("Found %d objects." % len(result["detection_scores"]))
    print("Inference time: ", end_time-start_time)

    image_with_boxes = draw_boxes(
        img.numpy(), result["detection_boxes"],
        result["detection_class_entities"], result["detection_scores"])

    print('here2')

    image_with_boxes_pil = Image.fromarray(np.uint8(image_with_boxes))
    image_with_boxes_pil.save('test_with_boxes.jpg', format="JPEG", quality=90)
 

    #delete the photos from local direotry

    

def generate_report():
    # Create a canvas and set the page size
    indian_timezone = pytz.timezone('Asia/Kolkata')

    current_date = datetime.now().date()
    formatted_date = current_date.strftime("%d/%m/%Y")

    current_time = datetime.now(indian_timezone).time()
    formatted_time = current_time.strftime("%H:%M:%S")


    count = 0 #id number fetched from database later

    count += 1


    
    c = canvas.Canvas("report.pdf", pagesize=letter)

    # Set the font and font size
    c.setFont("Helvetica", 12)

    # Add content to the report
    heading_style = c.beginText()
    heading_style.setFont("Helvetica-Bold", 24)
    heading_style.setTextOrigin(125, 750)
    heading_style.textLine("EmpowerNUS Evidence Report")
    c.drawText(heading_style)
    c.setFont("Helvetica", 12)

    x = 25  # Left position of the box
    y = 675  # Bottom position of the box
    width = letter[0] - 1 * inch  # Width of the box (subtracting the left and right margins)
    height = 50  # Height of the box
    c.rect(x, y, width, height)
    c.drawString(35, 700, f"User ReportID: {count}      Prepared By: EmpowerNUS      Report Time: {formatted_time}     Date: {formatted_date}")

    c.setLineWidth(2)  # Adjust the line width to make it bold
    c.setStrokeColorRGB(0, 0, 0)  # Set the color to black

    # Draw the separating line
    y = 650  # Adjust the y-coordinate according to your desired position
    c.line(x, y, 565, y)

    heading_style = c.beginText()
    heading_style.setFont("Helvetica-Bold", 20)
    heading_style.setTextOrigin(225, 615)
    heading_style.textLine("Legal Declaration")
    c.drawText(heading_style)

    
    c.setFont("Helvetica", 12)

    purpose = 'This report is generated by the EmpowerNUS Safety Application. The purpose of this report is to outline'
    purpose2= 'potentially dangerous activities harmful to the wellbeing of the user. This report also serves as a mean'
    purpose3= 'to help the relevant authorties in their criminal investigations.'

    c.drawString(25, 590, purpose)
    c.drawString(25, 570, purpose2)
    c.drawString(25, 550, purpose3)

    heading_style = c.beginText()
    heading_style.setFont("Helvetica-Bold", 20)
    heading_style.setTextOrigin(225, 510)
    heading_style.textLine("Evidence Collated")
    c.drawText(heading_style)
    #photo goes here
 



    #

    #parse image_url parameter
    image_path = 'test_with_boxes.jpg'
    image_width = 500
    image_height = image_width * letter[1] / letter[0]
    c.drawImage(image_path, 50,  250, width=500, height=250)

    #parse incident details
    c.setFont("Helvetica", 12)
    incident = ''

    heading_style = c.beginText()
    heading_style.setFont("Helvetica-Bold", 20)
    heading_style.setTextOrigin(225, 215)
    heading_style.textLine("Incident Details")
    c.drawText(heading_style) 

    c.drawString(25, 200, incident)

    margin = 50
    available_space = 500
    image_path = 'EmpowerNUS.png'
    image_width = 200
    image_height = image_width * letter[1] / letter[0]
    c.drawImage(image_path, 410,  -75, width=200, height=160)





    # Save the canvas and close it
    c.save()






reports = []


#Report generation endpoint for photos
@app.route('/reportGen', methods=['GET', 'POST'])
def reportGen():
    global reports
    if request.method == 'POST':
        # Get the data from the POST request
        data = request.get_json()
        # Add the data to the list
        reports.append(data)
        print('reached')
        global img_url
        img_url = reports[0]['Raw_Picture']
        run_detector(img_url)

        #work on report generation
        generate_report()


        reports = []

        return jsonify({'message': 'POST request received'}), 200
    else:
        # Return the list of images in the response to GET requests
        
        

        return reports

videos = []
theFiles = []
#Report generation endpoint for videos
@app.route('/reportGenVideos', methods=['GET', 'POST', 'DELETE'])
def reportGenVideos():
    index = 0
    global videos
    if request.method == 'POST':
        data = request.get_json()
        videos.append(data)

        
        global video_url
        video_url = videos[0]['Raw_Video']
        videoGeneration(video_url)
        index +=1
        videos = []

        frames_folder = 'frames_output'
        output_pdf_filename = 'output.pdf'
        create_pdf_from_images(frames_folder, output_pdf_filename)

        #upload that pdf onto firebase
        
        
        
        return jsonify({'message': 'POST request received'}), 200
    else:
        
           
        return jsonify(videos), 200
    
@app.route('/evidenceGeneration', methods = ['POST','GET'])
def evidenceGeneration():
   if request.method == 'POST':
      pass
   else:
      return jsonify(theFiles), 200
      
   

@app.route('/deleteVideoData', methods=['DELETE'])
def deleteVideoData():
    global videos
    if request.method == 'DELETE':
        if len(videos) > 0:
            # Remove the first JSON object from the list (index 0)
            removed_video = videos.pop(0)
            return jsonify({'message': 'Deleted the processed JSON object', 'deleted_video': removed_video}), 200
        else:
            return jsonify({'message': 'No JSON object to delete'}), 404


image_paths = []
desired_classes = ['gun','guns','person','people','vehicle','car','truck','bike','motorcycle','cycle','bicycle','bomb','canisters','canister','explosive','rope','chain','police','accident','license','driving plate','plate','fire']

def download_video(video_url, save_path):
    response = requests.get(video_url, stream=True)
    response.raise_for_status()

    with open(save_path, 'wb') as file:
        for chunk in response.iter_content(chunk_size=8192):
            file.write(chunk)

    print("Video downloaded successfully.")
    return save_path

def download_and_resize_videoImages(image_url, new_size):
  # Download the image from the URL
  headers = {
      "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"
  }
  
  # Open the downloaded image using PIL
  image = Image.open(image_url)
  image = ImageOps.fit(image, new_size, Image.LANCZOS)
  image = image.convert('RGB')
  # Resize the image
  image.save(image_url, format="JPEG", quality=90)
  
  return image_url



def videoGeneration(video_path_url):
    module_handle = "https://tfhub.dev/google/openimages_v4/ssd/mobilenet_v2/1" #pretrained model
    detector = hub.load(module_handle).signatures['default']

    # Function to create a folder if it doesn't exist
    def create_folder_if_not_exists(folder_path):
        if not os.path.exists(folder_path):
            os.makedirs(folder_path)

    output_folder = 'frames_output'
    create_folder_if_not_exists(output_folder)

    # Open video file from firebase 
    video_path = download_video(video_path_url, 'firebase_video.mp4')
    cap = cv2.VideoCapture(video_path)

    # Get the total number of frames and frame rate of the video
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    frame_rate = int(cap.get(cv2.CAP_PROP_FPS))

    # Calculate the intervals at which frames will be displayed
    intervals = [int(total_frames * i / 5) for i in range(1, 6)]  # 1/5th, 2/5th, 3/5th, 4/5th, and the end

    # Read and display the frames at the desired intervals
    for idx, interval in enumerate(intervals):
        cap.set(cv2.CAP_PROP_POS_FRAMES, interval)
        ret, frame = cap.read()

        if ret:
            frame_filename = os.path.join(output_folder, f'frame_{idx}.jpg')
            downloaded_image_path = download_and_resize_videoImages(frame_filename, (1280, 856))
            image_paths.append(frame_filename)
            cv2.imwrite(frame_filename, frame)
            if cv2.waitKey(1000) == ord('q'):  # Display each frame for 1 second, press 'q' to quit
                break

    # Release video capture and close all windows
    cap.release()
    cv2.destroyAllWindows()
    for img_path in image_paths:
        run_detector_videos(detector, img_path)


def draw_bounding_box_on_video_image(image,
                              ymin,
                              xmin,
                              ymax,
                              xmax,
                              color,
                              font,
                              thickness=4,
                              display_str_list=()):
  """Adds a bounding box to an image."""
  draw = ImageDraw.Draw(image)
  im_width, im_height = image.size
  (left, right, top, bottom) = (xmin * im_width, xmax * im_width,
                                ymin * im_height, ymax * im_height)
  draw.line([(left, top), (left, bottom), (right, bottom), (right, top),
            (left, top)],
            width=thickness,
            fill=color)

  # If the total height of the display strings added to the top of the bounding
  # box exceeds the top of the image, stack the strings below the bounding box
  # instead of above.
  font_size = 30
  display_str_heights = [font_size for ds in display_str_list]
  # Each display_str has a top and bottom margin of 0.05x.
  total_display_str_height = (1 + 2 * 0.05) * sum(display_str_heights)

  if top > total_display_str_height:
    text_bottom = top
  else:
    text_bottom = top + total_display_str_height
  # Reverse list and print from bottom to top.
  for display_str in display_str_list[::-1]:
    text_width, text_height = [font_size, font_size]
    margin = np.ceil(0.05 * text_height)
    draw.rectangle([(left, text_bottom - text_height - 2 * margin),
                    (left + text_width, text_bottom)],
                  fill=color)
    draw.text((left + margin, text_bottom - text_height - margin),
              display_str,
              fill="black",
              font=font)
    text_bottom -= text_height - 2 * margin

def draw_boxes_videos(image, boxes, class_names, scores, max_boxes=10, min_score=0.1):
  
  """Overlay labeled boxes on an image with formatted scores and label names."""
  colors = list(ImageColor.colormap.values())

  try:
    font = ImageFont.truetype("liberation-sans-narrow/LiberationSansNarrow-Regular.ttf",
                              25)
  except IOError:
    print("Font not found, using default font.")
    font = ImageFont.load_default()

  for i in range(min(boxes.shape[0], max_boxes)):
    if scores[i] >= min_score:
      ymin, xmin, ymax, xmax = tuple(boxes[i])
      display_str = "{}: {}%".format(class_names[i].decode("ascii"),
                                    int(100 * scores[i]))
        
      if class_names[i].decode("ascii") in desired_classes:
         color = 'red'
         display_str = "DANGEROUS: " + display_str
      else:
         color = colors[hash(class_names[i]) % len(colors)]
         display_str = "Moderate: " + display_str


         
      image_pil = Image.fromarray(np.uint8(image)).convert("RGB")
      draw_bounding_box_on_video_image(
          image_pil,
          ymin,
          xmin,
          ymax,
          xmax,
          color,
          font,
          display_str_list=[display_str])
      np.copyto(image, np.array(image_pil))
  return image



def run_detector_videos(detector, path):
  img = load_img(path)

  converted_img  = tf.image.convert_image_dtype(img, tf.float32)[tf.newaxis, ...]
  start_time = time.time()
  result = detector(converted_img)
  end_time = time.time()

  result = {key:value.numpy() for key,value in result.items()}

  print("Found %d objects." % len(result["detection_scores"]))
  print("Inference time: ", end_time-start_time)

  image_with_boxes = draw_boxes_videos(
      img.numpy(), result["detection_boxes"],
      result["detection_class_entities"], result["detection_scores"])

  image_with_boxes_pil = Image.fromarray(np.uint8(image_with_boxes))
  image_with_boxes_pil.save(path, format="JPEG", quality=90)
  



def create_pdf_from_images(folder_path, pdf_filename):
    # Get a list of image files in the folder
    image_files = [file for file in os.listdir(folder_path) if file.endswith(".jpg")]


    # Initialize the PDF canvas
    c = canvas.Canvas(pdf_filename, pagesize=letter)

    indian_timezone = pytz.timezone('Asia/Kolkata')

    current_date = datetime.now().date()
    formatted_date = current_date.strftime("%d/%m/%Y")

    current_time = datetime.now(indian_timezone).time()
    formatted_time = current_time.strftime("%H:%M:%S")


    count = 0 #id number fetched from database later

    count += 1

    # Set the font and font size
    c.setFont("Helvetica", 12)

    # Add content to the report
    heading_style = c.beginText()
    heading_style.setFont("Helvetica-Bold", 24)
    heading_style.setTextOrigin(125, 750)
    heading_style.textLine("EmpowerNUS Evidence Report")
    c.drawText(heading_style)
    c.setFont("Helvetica", 12)


    #set logo picture

    image_path = 'EmpowerNUS.png'
    image_width = 200
    image_height = image_width * letter[1] / letter[0] # aspect ratio
    c.drawImage(image_path, 490,  700, width=120, height=110)




    x = 25  # Left position of the box
    y = 675  # Bottom position of the box
    width = letter[0] - 1 * inch  # Width of the box (subtracting the left and right margins)
    height = 50  # Height of the box
    c.rect(x, y, width, height)
    c.drawString(35, 700, f"User ReportID: {count}      Prepared By: EmpowerNUS      Report Time: {formatted_time}     Date: {formatted_date}")

    c.setLineWidth(2)  # Adjust the line width to make it bold
    c.setStrokeColorRGB(0, 0, 0)  # Set the color to black

    # Draw the separating line
    y = 650  # Adjust the y-coordinate according to your desired position
    c.line(x, y, 565, y)

    heading_style = c.beginText()
    heading_style.setFont("Helvetica-Bold", 20)
    heading_style.setTextOrigin(225, 615)
    heading_style.textLine("Legal Declaration")
    c.drawText(heading_style)


    c.setFont("Helvetica", 12)

    purpose = 'This report is generated by the EmpowerNUS Safety Application. The purpose of this report is to outline'
    purpose2= 'potentially dangerous activities harmful to the wellbeing of the user. This report also serves as a mean'
    purpose3= 'to help the relevant authorties in their criminal investigations.'

    c.drawString(25, 590, purpose)
    c.drawString(25, 570, purpose2)
    c.drawString(25, 550, purpose3)

    heading_style = c.beginText()
    heading_style.setFont("Helvetica-Bold", 20)
    heading_style.setTextOrigin(225, 510)
    heading_style.textLine("Evidence Collated")
    c.drawText(heading_style)
    c.setFont("Helvetica", 12)

  
    purpose = 'The picture(s) below were captured from the app\'s photo/video capture. Our AI algorithm has highlighted'
    purpose2= 'potentially dangerous objects for review.'


    c.drawString(25, 490, purpose)
    c.drawString(25, 470, purpose2)

    # Set initial y position for stacking images
    y_offset = 200
    max_y_offset = 50  # Adjust this value to set the maximum y offset for images on a single page

    # Loop through the image files and stack them on top of each other in the PDF
    for image_file in image_files:
        image_path = os.path.join(folder_path, image_file)

        # Open the image using Pillow
        image = Image.open(image_path)

        # Calculate the aspect ratio of the image to fit it into the PDF
        width, height = image.size
        aspect_ratio = width / height

        # Calculate the new width and height to fit into the PDF
        image_width = 300
        image_height = 250

        # Check if the image will overflow the current page
        if y_offset - image_height < 0:
            # Start a new page
            c.showPage()
            y_offset = 500 

        # Draw the image on the PDF canvas
        c.drawImage(image_path, 150, y_offset, width=image_width, height=image_height)

        # Adjust the y position for the next image
        y_offset -= image_height + 20

    # Save the PDF
    c.save()


if __name__ == "__main__":
    app.run(debug=True)

