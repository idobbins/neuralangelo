# Neuralangelo Pipeline Script

# Environment variables (modify these as needed)
$env:SEQUENCE = "mercedes"
$env:INPUT_FILE = "mercedes.mp4"  # This should be the name of your input file
$env:PATH_TO_VIDEO = "/app/input/$env:INPUT_FILE"
$env:DOWNSAMPLE_RATE = 2
$env:SCENE_TYPE = "object"
$env:DATA_PATH = "/app/output/${env:SEQUENCE}_ds${env:DOWNSAMPLE_RATE}"
$env:EXPERIMENT = "toy_example"
$env:GROUP = "example_group"
$env:NAME = "example_name"
$env:CONFIG = "/app/project/projects/neuralangelo/configs/custom/${env:EXPERIMENT}.yaml"
$env:GPUS = 1
$env:CHECKPOINT = "/app/output/logs/${env:GROUP}/${env:NAME}/xxx.pt"
$env:OUTPUT_MESH = "/app/output/xxx.ply"
$env:RESOLUTION = 2048
$env:BLOCK_RES = 128

# Get the current directory
$currentDir = (Get-Location).Path

# Ensure input and output directories exist
New-Item -ItemType Directory -Force -Path "$currentDir\input" | Out-Null
New-Item -ItemType Directory -Force -Path "$currentDir\output" | Out-Null

# Verify that the input file exists
if (-not (Test-Path "$currentDir\input\$env:INPUT_FILE")) {
    Write-Error "Input file $env:INPUT_FILE not found in $currentDir\input. Please make sure the file is in the correct location."
    exit 1
}

# Function to run Docker Compose commands
function Run-DockerComposeCommand {
    param (
        [string]$Service,
        [string]$Command
    )
    docker compose run --rm $Service sh -c "$Command"
}

# Step 1: Preprocess data
#Write-Host "Starting preprocessing..."
Run-DockerComposeCommand "colmap" "bash /app/project/projects/neuralangelo/scripts/preprocess.sh ${env:SEQUENCE} ${env:PATH_TO_VIDEO} ${env:DOWNSAMPLE_RATE} ${env:SCENE_TYPE}"

# Step 2: Run COLMAP (if not already done in preprocessing)
#Run-DockerComposeCommand "colmap" "bash /app/project/projects/neuralangelo/scripts/run_colmap.sh ${env:DATA_PATH}"

# Step 3: Generate JSON file
#Run-DockerComposeCommand "colmap" "python3 /app/project/projects/neuralangelo/scripts/convert_data_to_json.py --data_dir ${env:DATA_PATH} --scene_type ${env:SCENE_TYPE}"

# Step 4: Generate config files
#Run-DockerComposeCommand "neuralangelo" "python3 /app/project/projects/neuralangelo/scripts/generate_config.py --sequence_name ${env:SEQUENCE} --data_dir ${env:DATA_PATH} --scene_type ${env:SCENE_TYPE}"

# Step 5: Run Neuralangelo training
#Run-DockerComposeCommand "neuralangelo" "torchrun --nproc_per_node=${env:GPUS} /app/project/train.py --logdir=/app/output/logs/${env:GROUP}/${env:NAME} --config=${env:CONFIG} --show_pbar"

# Step 6: Extract isosurface mesh
#Run-DockerComposeCommand "neuralangelo" "torchrun --nproc_per_node=${env:GPUS} /app/project/projects/neuralangelo/scripts/extract_mesh.py --config=${env:CONFIG} --checkpoint=${env:CHECKPOINT} --output_file=${env:OUTPUT_MESH} --resolution=${env:RESOLUTION} --block_res=${env:BLOCK_RES}"

#Write-Host "Neuralangelo pipeline completed successfully!"