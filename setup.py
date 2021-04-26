from setuptools import setup

setup(
    name='vsim',
    version='0.0.1',
    description='Open Source Verilog Module Library',
    url='https://github.com/aolofsson/oh',
    author='Andreas Olofsson',
    package_dir={'': 'src'},
    python_requires='>=3.7',    
    scripts=[],
    packages=[
        'vsim'
    ],
    license='Apache License 2.0',    
)
