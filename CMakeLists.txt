cmake_minimum_required(VERSION 3.27)
project(personal_project_clion)

set(CMAKE_CXX_STANDARD 14)

find_package(OpenCV REQUIRED)

add_executable(personal_project_clion
        Logic_Verification/Convolver_CNN/convolver_cpp_imp.cpp)

target_link_libraries(personal_project_clion
        ${OpenCV_LIBS}
)
