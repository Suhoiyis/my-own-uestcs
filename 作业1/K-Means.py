import numpy as np
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans
import re

plt.rcParams['font.sans-serif'] = ['Microsoft YaHei']
plt.rcParams['axes.unicode_minus'] = False

# 定义要读取的文件名
file_path = 'data.txt'

try:
    # 打开并读取文件内容
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 使用正则表达式找到所有数值
    numbers = re.findall(r'[-+]?\d*\.\d+e[-+]\d+', content)

    # 将字符串转换为浮点数
    data_list = [float(num) for num in numbers]

    # 将数据转换为Numpy数组，整理为二维坐标点
    if len(data_list) % 2 != 0:
        data_list = data_list[:-1]
    data = np.array(data_list).reshape(-1, 2)

    # 创建KMeans模型，聚类数量为4
    kmeans = KMeans(n_clusters=4, random_state=42, n_init=10)

    # 拟合数据
    kmeans.fit(data)

    # 获取聚类标签和中心点
    labels = kmeans.labels_
    centers = kmeans.cluster_centers_

    # 可视化
    plt.figure(figsize=(10, 8))
    scatter = plt.scatter(data[:, 0], data[:, 1], c=labels, cmap='viridis', marker='o', label='数据点')
    plt.scatter(centers[:, 0], centers[:, 1], c='red', s=200, alpha=0.75, marker='x', label='聚类中心')
    plt.title('K-Means 聚类结果 (4个簇)')
    plt.xlabel('X 坐标')
    plt.ylabel('Y 坐标')
    plt.legend()
    plt.grid(True)

    # 保存图像
    plt.savefig('output.png')

    print(f"成功从 {file_path} 文件读取数据并完成聚类。")
    print(f"数据点总数: {len(data)}")
    print("聚类中心:")
    print(centers)
    print("聚类结果图像已保存为 output.png")

except FileNotFoundError:
    print(f"错误：无法找到文件 '{file_path}'。")

except Exception as e:
    print(f"处理文件时发生错误: {e}")