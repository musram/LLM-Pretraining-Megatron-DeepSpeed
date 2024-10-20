# LLM training with Megatron-DeepSpeed


- Run the following commands to start the container and get a shell into it:

  - Build the Podman image:

    ```
    podman build -t megatron-deepspeed-image .
    ```

    or if docker-compose.yml file is present then compose and build the container with the following command:

    ```
    podman-compose up -d --build megatron-deepspeed
    ```
    or 
    ```
    podman -compose up -d 
    podman run --name megatron-deepspeed localhost/llm-md
    ```

  
  - Verify the container is running:

    ```
    podman ps
    ```

  - Execute a shell in the running container:

    ```
    podman exec -it -e WANDB_API_KEY=f831d81ce78350019acca3bcd41969beca447b2a -e HF_TOKEN=sss sft-pipeline bash
    ```
    or 
    ```
    docker exec -it sft-pipeline bash -c 'export WANDB_API_KEY=f831d81ce78350019acca3bcd41969beca447b2a && export HF_TOKEN=sss && bash'
    ```
  - Inside the container, run the script to start the training:
    ```
    python sft_pipeline/main.py
    ```

- ```bash
  export NCCL_NVLS_ENABLE=0
  ```

- ```bash
  accelerate launch --config_file=deepspeed_zero2.yaml --gradient_accumulation_steps 8 sft_pipeline/main.py \
    --seed 42 \
    --packing False \
    --output_dir "output_dir" \
    --num_train_epochs 3 \
    --per_device_train_batch_size 3 \
    --gradient_accumulation_steps 2 \
    --optim "adamw_torch_fused" \
    --logging_steps 10 \
    --save_strategy "epoch" \
    --learning_rate 2e-4 \
    --bf16 \
    --tf32 \
    --max_grad_norm 0.3 \
    --warmup_ratio 0.1 \
    --lr_scheduler_type "cosine" \
    --report_to "tensorboard" \
    --dataset_batch_size 1000 \
    --neftune_noise_alpha 0.1 \
    --eval_packing False \
    --num_of_sequences 1024 \
    --chars_per_token 3.6 \
    --max_steps -1 \
    --save_steps 500 \
    --save_total_limit 3 \
    --log_with "tensorboard" \
    --evaluation_strategy "epoch" \
    --model_name_or_path "model/Llama-3.2-3B" \
    --trust_remote_code \
    --model_revision "main" \
    --attn_implementation "flash_attention_2" \
    --torch_dtype "auto" \
    --use_cache \
    --lora_task_type "CAUSAL_LM" \
    --lora_r 16 \
    --lora_target_modules "q_proj" "v_proj" \
    --lora_alpha 32 \
    --lora_dropout 0.05 \
    --use_rslora \
    --lora_modules_to_save "embed_tokens" "lm_head" \
    --seq_length 4096 \
    --log_level "info" \
    --dataset_dir "data/few_shot/few_shot_part_1.parquet" \
    --dataset_train_test_split 0.1 \
    --task_name "NLP:Few Shot Learning" \
    --bnb_4bit_compute_dtype "float16" \
    --bnb_4bit_quant_type "fp4" \
    --use_bnb_nested_quant \
    --bnb_4bit_quant_storage "float16" \
    --load_in_4bit
  ```




./pretrain_qvac_distributed.sh my-project my-experiment









### References
- [**Megatron-DeepSpeed by Habana AI**](https://github.com/HabanaAI/Megatron-DeepSpeed/tree/main)