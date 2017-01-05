FROM ubuntu:16.04
RUN apt-get update
RUN apt-get install -y git python-pip pkg-config libpng-dev libfreetype6-dev r-base wget libssl-dev libcurl4-openssl-dev openjdk-8-jdk-headless
RUN echo 'options(repos = "http://cran.rstudio.com/"); install.packages(c("mlr", "devtools", "DiceKriging", "randomForest"))' | R --no-save --quiet
RUN echo 'require(devtools); install_github("mlr-org/mlrmbo"); install_github("mllg/batchtools"); install_github("berndbischl/ParamHelpers", ref="generate_default_design")' | R --no-save --quiet
RUN git clone https://github.com/ja-thomas/HPOlib.git
WORKDIR HPOlib
RUN git checkout development
RUN pip install --upgrade pip
RUN pip install virtualenv
RUN virtualenv virtualHPOlib
RUN bash virtualHPOlib/bin/activate
RUN easy_install -U distribute
RUN pip install numpy==1.8.1
RUN pip install scipy==0.13.2
RUN pip install scikit-learn==0.15.1
RUN pip install matplotlib
RUN pip install nose
RUN pip install glob
RUN pip install pickle
RUN pip install pandas
RUN python setup.py install
RUN wget http://www.automl.org/downloads/surrogate/hpnnet_surrogate.tar.gz
RUN wget http://www.automl.org/downloads/surrogate/hpdbnet_surrogate.tar.gz
RUN tar xf hpnnet_surrogate.tar.gz
RUN tar xf hpdbnet_surrogate.tar.gz
RUN git clone https://github.com/KEggensperger/SurrogateBenchmarks
RUN cd SurrogateBenchmarks && python setup.py install
RUN find hpdbnet -name 'config.cfg' -exec sed -i -e 's/\~\/socketdir/\/tmp/g' {} +
RUN find hpnnet -name 'config.cfg' -exec sed -i -e 's/\~\/socketdir/\/tmp/g' {} +
RUN cd batchexps && parallel -j 10 --progess --eta < calls
RUN python batchexps/reduce_result.py


