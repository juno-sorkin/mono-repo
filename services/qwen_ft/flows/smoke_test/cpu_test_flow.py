from metaflow import FlowSpec, step, batch, resources

class CPUTestFlow(FlowSpec):
    """
    A simple smoke test to verify that Metaflow can launch a CPU job on AWS Batch.
    """

    @step
    def start(self):
        """
        The entry point of the flow.
        """
        print("Flow started. Next step will run on AWS Batch.")
        self.next(self.cpu_step)

    @batch(cpu=1, memory=500)
    @step
    def cpu_step(self):
        """
        This step runs on a CPU instance in AWS Batch.
        """
        import platform
        print("Hello from AWS Batch!")
        print(f"Python version: {platform.python_version()}")
        print("CPU job finished successfully.")
        self.next(self.end)

    @step
    def end(self):
        """
        The end of the flow.
        """
        print("Flow finished.")

if __name__ == "__main__":
    CPUTestFlow()
