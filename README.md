# Training-Large-Scale-ONN
Training Large-Scale Optical Neural Networks with Two-Pass Forward Propagation


#1- design_device.mat: As you know, designing a simple MZI in MATLAB can be challenging, so we first import an MZI image from Lumerical and then define the refractive index to create the simple MZI units. By placing them in a mesh, we create a 4x4 mesh, which will be used in the next step for the FDTD code.

#2- FDTF.mat:In this code, we implement the Finite-Difference Time-Domain (FDTD) method with Perfectly Matched Layer (PML) boundary conditions to accurately calculate the electric field values in our simulation.

#3- Error_Drive: In this code, we test a novel approach for training neural networks. The idea involves modulating the error by applying a random matrix 𝐹. This modulated error is then reintroduced into the model during the training process.

#4- Large_Scale_Data_Processin: In this code, we demonstrate a large-scale training procedure for in-silico models and validate its effectiveness by training it on the MNIST dataset. This helps ensure that the proposed approach functions well.

#5- Optical_Neural_Network: In this code, we first implement a simple artificial neural network (ANN) optically using a mesh of Mach-Zehnder Interferometers (MZIs) and train it using backpropagation.
Next, we explore two additional approaches: training a large-scale model and employing a forward propagation idea. Both methods are applied to the mesh of MZIs to evaluate their performance and obtain the final results.
