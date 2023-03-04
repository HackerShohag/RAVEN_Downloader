/* youtube-dl-qt is Free Software: You can use, study share
 * and improve it at your will. Specifically you can redistribute
 * and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 * 
 * The original author of this code : Robin de Rooij (https://github.com/rrooij)
 * The original repository of this code : https://github.com/rrooij/youtube-dl-qt 
 */

#include "mediaformat.h"

MediaFormat::MediaFormat(QObject *parent) : QObject{parent}
{

}

QString MediaFormat::getTitle() const
{
    return this->m_title;
}

void MediaFormat::setTitle(QString value)
{
    this->m_title = value;
    emit titleChanged(value);
}

QStringList MediaFormat::getFormatId() const
{
    return this->m_formatId;
}

void MediaFormat::setFormatIdItem(QString value)
{
    this->m_formatId << value;
}

QStringList MediaFormat::getExtension() const
{
    return this->m_extension;
}

void MediaFormat::setExtensionItem(QString value)
{
    this->m_extension << value;
}

QStringList MediaFormat::getResolution() const
{
    return this->m_resolution;
}

void MediaFormat::setResolutionItem(QString value)
{
    this->m_resolution << value;
}

QStringList MediaFormat::getQuality() const
{
    return this->m_quality;
}

void MediaFormat::setQualityItem(QString value)
{
    this->m_quality << value;
}

QStringList MediaFormat::getNote() const
{
    return this->m_note;
}

void MediaFormat::setNoteItem(QString value)
{
    this->m_note << value;
}

QStringList MediaFormat::getFormat() const
{
    return this->m_format;
}

void MediaFormat::setFormatItem(QString value)
{
    this->m_format << value;
}

QStringList MediaFormat::getAcodec() const
{
    return this->m_acodec;
}

void MediaFormat::setAcodecItem(QString value)
{
    this->m_acodec << value;
}

QStringList MediaFormat::getVcodec() const
{
    return this->m_vcodec;
}

void MediaFormat::setVcodecItem(QString value)
{
    this->m_vcodec << value;
}

QStringList MediaFormat::getUrl() const
{
    return this->m_url;
}

void MediaFormat::setUrlItem(QString value)
{
    this->m_url << value;
}

QString MediaFormat::getThumbnail() const
{
    return m_thumbnail;
}

void MediaFormat::setThumbnail(QString value)
{
    this->m_thumbnail = value;
    emit thumbnailChanged(value);
}

QList<double> MediaFormat::getFilesize() const
{
    return this->m_filesize;
}

void MediaFormat::setFilesizeItem(double value)
{
    this->m_filesize << value;
}

void MediaFormat::clearClutter()
{
    this->m_title.clear();
    this->m_thumbnail.clear();
    this->m_duration.clear();
    this->m_formatId.clear();
    this->m_format.clear();
    this->m_extension.clear();
    this->m_resolution.clear();
    this->m_quality.clear();
    this->m_note.clear();
    this->m_acodec.clear();
    this->m_vcodec.clear();
    this->m_url.clear();
    this->m_filesize.clear();
}

QString MediaFormat::getDuration() const
{
    return this->m_duration;
}

void MediaFormat::setDuration(QString value)
{
    this->m_duration = value;
    emit durationChanged(value);
}
