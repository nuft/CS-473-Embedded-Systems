#ifndef CAMERA_H
#define CAMERA_H

void camera_enable(void);
void camera_disable(void);
void camera_setup(void *buf, void (*isr)(void *), void *isr_arg);
void camera_set_frame_buffer(void *buf);

#endif /* CAMERA_H */