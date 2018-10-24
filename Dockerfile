# We will use Ubuntu for our image
FROM ubuntu

# Update Ubuntu packages
RUN apt-get update && yes|apt-get upgrade

# Add wget and bzip2
RUN apt-get install -y wget bzip2

######################################
# Install Anaconda
#
RUN wget https://repo.continuum.io/archive/Anaconda3-5.0.1-Linux-x86_64.sh
RUN bash Anaconda3-5.0.1-Linux-x86_64.sh -b
RUN rm Anaconda3-5.0.1-Linux-x86_64.sh

# Set path to conda
ENV PATH /root/anaconda3/bin:$PATH

# Update Anaconda packages
RUN conda update conda
RUN conda update anaconda
RUN conda update --all
######################################


######################################
# Install TensorFlow via conda
#
# Create a new virtual environment by choosing a Python interpreter and making a ./venv directory to hold it:
RUN conda create -n venv pip python=3.6
# Activate the virtual environment:
RUN /bin/bash -c "source activate venv"
# Within the virtual environment, install the TensorFlow pip package using its complete URL:
# (https://www.tensorflow.org/install/pip#package-location)
RUN pip install --ignore-installed --upgrade https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-1.11.0-cp36-cp36m-linux_x86_64.whl
RUN python3 -c "import tensorflow as tf; print(tf.__version__)"
# Exit virtualenv later:
#RUN /bin/bash -c "source deactivate"
######################################


# Configure access to Jupyter
RUN mkdir /opt/project
RUN jupyter notebook --generate-config --allow-root
#RUN echo "c.NotebookApp.password = u'sha1:6a3f528eec40:6e896b6e4828f525a6e20e5411cd1c8075d68619'" >> /root/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.allow_remote_access = True" >> ~/.jupyter/jupyter_notebook_config.py

# Jupyter listens port: 8888
EXPOSE 8888

# Set working directory
WORKDIR /opt/project

# Copy examples
ADD . /opt/project

# Run Jupyter notebook as Docker main process
CMD ["jupyter", "notebook", "--allow-root", "--notebook-dir=/opt/project", "--ip='*'", "--port=8888", "--no-browser"]
