# 路测数据标注任务

1. 将你的数据包解压后放在`input/NuScenes`目录下  
2. 修改`js/base_label_tool.js`文件中第三行对应的当前序列的名字，该名字与步骤1中的文件夹名字相同  
3. 按照说明开始标注，通过点击控制面板中的`Download Annotations`按钮下载你的标注文件，下载默认目录是你的浏览器对应的默认目录，下载文件名默认为`Nuscenes_${数据段名称}_annotations.txt`，将该文件拷贝到`input/Nuscenes/${数据段名称}/annotations/LIDAR_TOP`目录下,下次重新打开工具或刷新工具都可以从上次保存的标注文件基础上继续标注。